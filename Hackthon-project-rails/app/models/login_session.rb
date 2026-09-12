class LoginSession < ApplicationRecord
  belongs_to :user
  scope :active, -> { where("expires_at > ?", Time.current) }

  def self.issue!(user)
    token = SecureRandom.hex(32)
    create!(user: user, token_digest: Digest::SHA256.hexdigest(token), expires_at: 7.days.from_now)
    where("expires_at <= ?", Time.current).delete_all
    token
  end

  def self.for_token(token)
    return unless token.present?
    active.find_by(token_digest: Digest::SHA256.hexdigest(token))
  end
end
