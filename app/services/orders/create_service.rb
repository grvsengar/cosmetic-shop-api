module Orders
  class CreateService
    Result = Struct.new(:success?, :order, :razorpay_key_id, :errors)

    def self.call(user, params)
      new(user, params).call
    end

    def initialize(user, params)
      @user   = user
      @params = params
    end

    def call
      ActiveRecord::Base.transaction do
        items  = build_items
        total  = calculate_total(items)
        rzp    = create_razorpay_order(total)
        order  = persist_order(items, total, rzp)

        Result.new(true, order, ENV.fetch("RAZORPAY_KEY_ID", ""), [])
      end
    rescue Razorpay::BadRequestError => e
      Result.new(false, nil, nil, ["Payment gateway error: #{e.message}"])
    rescue ActiveRecord::RecordInvalid => e
      Result.new(false, nil, nil, e.record.errors.full_messages)
    rescue RuntimeError => e
      Result.new(false, nil, nil, [e.message])
    end

    private

    def build_items
      (@params[:items] || []).map do |item|
        product = Product.find(item[:product_id])
        qty     = item[:quantity].to_i
        raise "Quantity must be at least 1 for #{product.name}" if qty < 1
        raise "Only #{product.stock_count} left in stock for #{product.name}" if qty > product.stock_count
        { product: product, quantity: qty }
      end
    end

    def calculate_total(items)
      items.sum { |i| i[:product].price * i[:quantity] }
    end

    def create_razorpay_order(total)
      Razorpay::Order.create(
        amount:   (total * 100).to_i,   # Razorpay expects paise
        currency: "INR",
        receipt:  "rcpt_#{SecureRandom.hex(8)}",
        notes:    { customer_email: @user.email }
      )
    end

    def persist_order(items, total, rzp_order)
      order = @user.orders.create!(
        address:           @params[:address],
        total:             total,
        status:            :pending,
        razorpay_order_id: rzp_order.id
      )

      items.each do |item|
        item[:product].decrement_stock!(item[:quantity])
        order.order_items.create!(
          product:    item[:product],
          quantity:   item[:quantity],
          unit_price: item[:product].price
        )
      end

      order
    end
  end
end
