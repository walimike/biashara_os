class User < ApplicationRecord
  ROLES = %w[owner manager cashier].freeze

  belongs_to :organization
  has_many :orders, dependent: :nullify

  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { scope: :organization_id, case_sensitive: false }
  validates :role, inclusion: { in: ROLES }

  before_validation :normalize_email

  def owner?
    role == "owner"
  end

  private

    def normalize_email
      self.email = email.to_s.strip.downcase
    end
end
