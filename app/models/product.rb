class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items, dependent: :restrict_with_error
  has_many_attached :images

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :stock_count, numericality: { greater_than_or_equal_to: 0 }

  scope :in_stock, -> { where("stock_count > 0") }

  def image_urls
    images.attached? ? images.map { |img| img.url } : []
  end

  def decrement_stock!(qty)
    with_lock do
      raise "Insufficient stock" if stock_count < qty
      decrement!(:stock_count, qty)
    end
  end
end
