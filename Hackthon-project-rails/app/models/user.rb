class User < ApplicationRecord
  has_secure_password
  has_one :hack_application, dependent: :destroy
  has_many :login_sessions, dependent: :destroy
  before_validation { self.email = email.to_s.strip.downcase; self.name = name.to_s.strip }
  validates :name, length: { in: 2..100 }
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, length: { maximum: 254 }, uniqueness: true
  validates :role, inclusion: { in: %w[hacker mentor organizer] }
  validates :password, length: { minimum: 12, maximum: 72 }, if: -> { password.present? }
  validates :password_confirmation, presence: true, if: -> { password.present? }

  def organizer?
    role == "organizer"
  end

  def mentor?
    role == "mentor"
  end
end
