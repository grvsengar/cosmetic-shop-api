class WebhooksController < ApplicationController
  def razorpay
    payload   = request.raw_post
    signature = request.headers["X-Razorpay-Signature"].to_s

    unless valid_signature?(payload, signature)
      return render json: { error: "Invalid signature" }, status: :unauthorized
    end

    event = JSON.parse(payload)
    handle_event(event)
    head :ok
  rescue JSON::ParserError
    render json: { error: "Invalid payload" }, status: :bad_request
  end

  private

  def valid_signature?(payload, signature)
    expected = OpenSSL::HMAC.hexdigest(
      "SHA256",
      ENV.fetch("RAZORPAY_WEBHOOK_SECRET", ""),
      payload
    )
    ActiveSupport::SecurityUtils.secure_compare(expected, signature)
  end

  def handle_event(event)
    return unless event["event"] == "payment.captured"

    payment            = event.dig("payload", "payment", "entity") || {}
    razorpay_order_id  = payment["order_id"]
    razorpay_payment_id = payment["id"]

    return if razorpay_order_id.blank? || razorpay_payment_id.blank?

    # Idempotency: skip if this payment_id was already processed (T5)
    return if Order.exists?(razorpay_payment_id: razorpay_payment_id)

    order = Order.find_by(razorpay_order_id: razorpay_order_id)
    unless order
      Rails.logger.warn "Razorpay webhook: unknown order_id #{razorpay_order_id}"
      return
    end

    order.update!(status: :paid, razorpay_payment_id: razorpay_payment_id)
    Rails.logger.info "Order ##{order.id} marked paid via Razorpay payment #{razorpay_payment_id}"
  end
end
