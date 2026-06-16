FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { "A great product." }
    price        { 299.0 }
    stock_count  { 10 }
    association  :category
  end
end
