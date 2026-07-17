class Product < ApplicationRecord
  belongs_to :organization
  has_many :order_items, dependent: :nullify

  scope :active, -> { where(active: true) }
  scope :ordered, -> { order(:name) }

  validates :name, presence: true
  validates :price_cents, numericality: { greater_than_or_equal_to: 0 }
  validates :stock_quantity, numericality: { only_integer: true }
  validates :sku, uniqueness: { scope: :organization_id, allow_nil: true }

  def price
    price_cents / 100.0
  end
end
