class LoginAttempt < ApplicationRecord
  # Persist the limit so restarting the web service does not reset it.
  def self.allowed?(email)
    digest = Digest::SHA256.hexdigest(email.to_s.strip.downcase.first(254))
    record = create_or_find_by!(email_digest: digest) { |row| row.reset_at = 15.minutes.from_now }
    record.with_lock do
      record.assign_attributes(attempts: 0, reset_at: 15.minutes.from_now) if record.reset_at <= Time.current
      record.attempts += 1
      record.save!
      record.attempts <= 10
    end
  end
end
