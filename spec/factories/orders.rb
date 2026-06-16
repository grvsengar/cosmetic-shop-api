FactoryBot.define do
  factory :order do
    association :user
    status            { :pending }
    total             { 999.0 }
    razorpay_order_id { "order_#{SecureRandom.hex(8)}" }
    razorpay_payment_id { nil }
    address           { "123 MG Road, Bhopal MP 462001" }
  end
end
