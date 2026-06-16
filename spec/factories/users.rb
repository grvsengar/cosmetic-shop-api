FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "Password123!" }
    role     { :customer }

    trait :admin do
      role { :admin }
    end
  end
end
