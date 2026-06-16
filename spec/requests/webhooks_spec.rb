require "rails_helper"

RSpec.describe "POST /webhooks/razorpay", type: :request do
  let(:secret)  { "test_webhook_secret" }
  let(:order)   { create(:order, razorpay_order_id: "order_test123", status: :pending) }

  before { allow(ENV).to receive(:fetch).and_call_original }
  before { allow(ENV).to receive(:fetch).with("RAZORPAY_WEBHOOK_SECRET", "").and_return(secret) }

  def sign(payload)
    OpenSSL::HMAC.hexdigest("SHA256", secret, payload)
  end

  def post_webhook(payload_hash, sig: nil)
    body = payload_hash.to_json
    post "/webhooks/razorpay",
      params: body,
      headers: {
        "Content-Type"          => "application/json",
        "X-Razorpay-Signature"  => sig || sign(body)
      }
  end

  def payment_captured_payload(order_id:, payment_id:)
    {
      event: "payment.captured",
      payload: {
        payment: {
          entity: { id: payment_id, order_id: order_id }
        }
      }
    }
  end

  it "marks order as paid on payment.captured" do
    post_webhook(payment_captured_payload(order_id: order.razorpay_order_id, payment_id: "pay_abc123"))
    expect(response).to have_http_status(:ok)
    expect(order.reload.status).to eq("paid")
    expect(order.reload.razorpay_payment_id).to eq("pay_abc123")
  end

  it "returns 401 for invalid signature" do
    post_webhook(
      payment_captured_payload(order_id: order.razorpay_order_id, payment_id: "pay_xyz"),
      sig: "bad_signature"
    )
    expect(response).to have_http_status(:unauthorized)
    expect(order.reload.status).to eq("pending")
  end

  it "is idempotent — ignores duplicate payment_id (T5)" do
    order.update!(razorpay_payment_id: "pay_already_done", status: :paid)
    expect do
      post_webhook(payment_captured_payload(order_id: order.razorpay_order_id, payment_id: "pay_already_done"))
    end.not_to change { order.reload.updated_at }
    expect(response).to have_http_status(:ok)
  end

  it "returns 200 and logs for unknown order_id (does not raise)" do
    post_webhook(payment_captured_payload(order_id: "order_unknown", payment_id: "pay_noop"))
    expect(response).to have_http_status(:ok)
  end

  it "ignores non-payment events" do
    post_webhook({ event: "order.paid", payload: {} })
    expect(response).to have_http_status(:ok)
    expect(order.reload.status).to eq("pending")
  end

  it "returns 400 for malformed JSON" do
    post "/webhooks/razorpay",
      params: "not-json{{{",
      headers: {
        "Content-Type"         => "application/json",
        "X-Razorpay-Signature" => sign("not-json{{{")
      }
    expect(response).to have_http_status(:bad_request)
  end
end
