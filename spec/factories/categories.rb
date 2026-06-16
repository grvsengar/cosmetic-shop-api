FactoryBot.define do
  factory :category do
    sequence(:name) { |n| "Category #{n}" }
    slug { name.downcase.gsub(/\s+/, "-") }
  end
end
