class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items

  enum :status, {
    pending: "pending",
    paid: "paid",
    processing: "processing",
    shipped: "shipped",
    delivered: "delivered",
    cancelled: "cancelled"
  }

  validates :address, :total, presence: true
  validates :razorpay_payment_id, uniqueness: true, allow_nil: true
end
