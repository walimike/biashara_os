class Organization < ApplicationRecord
  MODULES = %w[order_pad pos inventory invoicing].freeze

  has_many :users, dependent: :destroy
  has_many :products, dependent: :destroy
  has_many :customers, dependent: :destroy
  has_many :orders, dependent: :destroy

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true, format: { with: /\A[a-z0-9-]+\z/ }
  validates :currency, presence: true
  validates :plan, presence: true
  validate :enabled_modules_are_valid

  before_validation :generate_slug, on: :create

  def module_enabled?(mod)
    enabled_modules.include?(mod.to_s)
  end

  private

    def generate_slug
      return if slug.present?

      base = name.to_s.parameterize
      candidate = base
      suffix = 1
      while Organization.exists?(slug: candidate)
        candidate = "#{base}-#{suffix}"
        suffix += 1
      end
      self.slug = candidate
    end

    def enabled_modules_are_valid
      invalid = enabled_modules - MODULES
      errors.add(:enabled_modules, "contains invalid modules: #{invalid.join(', ')}") if invalid.any?
    end
end
