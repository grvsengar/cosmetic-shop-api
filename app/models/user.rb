class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: JwtDenylist

  enum :role, { customer: 0, admin: 1 }, default: :customer

  has_many :orders, dependent: :destroy
  has_one :cart, dependent: :destroy
end
