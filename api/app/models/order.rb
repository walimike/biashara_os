class Order < ApplicationRecord
  SOURCES = %w[order_pad pos].freeze
  STATUSES = %w[pending confirmed completed cancelled].freeze
  PAYMENT_STATUSES = %w[unpaid partial paid].freeze
  PAYMENT_METHODS = %w[cash mpesa].freeze

  belongs_to :organization
  belongs_to :customer, optional: true
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  accepts_nested_attributes_for :order_items, allow_destroy: true

  validates :order_number, presence: true, uniqueness: { scope: :organization_id }
  validates :source, inclusion: { in: SOURCES }
  validates :status, inclusion: { in: STATUSES }
  validates :payment_status, inclusion: { in: PAYMENT_STATUSES }
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }, allow_nil: true

  before_validation :assign_order_number, on: :create
  before_save :recalculate_totals

  scope :recent, -> { order(created_at: :desc) }
  scope :today, -> { where(created_at: Time.zone.today.all_day) }

  def recalculate_totals!
    self.subtotal_cents = order_items.sum(&:line_total_cents)
    self.total_cents = subtotal_cents
    save!
  end

  private

    def assign_order_number
      return if order_number.present?

      date_prefix = Time.zone.today.strftime("%Y%m%d")
      last_today = organization.orders.where("order_number LIKE ?", "#{date_prefix}-%").order(:order_number).last
      sequence = last_today ? last_today.order_number.split("-").last.to_i + 1 : 1
      self.order_number = format("%s-%03d", date_prefix, sequence)
    end

    def recalculate_totals
      return unless order_items.loaded? || order_items.any?

      self.subtotal_cents = order_items.reject(&:marked_for_destruction?).sum(&:line_total_cents)
      self.total_cents = subtotal_cents
    end
end
