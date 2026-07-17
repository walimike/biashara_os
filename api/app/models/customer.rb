class Customer < ApplicationRecord
  belongs_to :organization
  has_many :orders, dependent: :nullify

  scope :ordered, -> { order(:name) }

  validates :name, presence: true
end
