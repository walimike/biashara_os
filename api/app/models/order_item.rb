class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product, optional: true

  validates :name, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :unit_price_cents, numericality: { greater_than_or_equal_to: 0 }

  before_validation :sync_from_product
  before_validation :calculate_line_total

  private

    def sync_from_product
      return unless product

      self.name ||= product.name
      self.unit_price_cents = product.price_cents if unit_price_cents.zero?
    end

    def calculate_line_total
      self.line_total_cents = quantity.to_i * unit_price_cents.to_i
    end
end
