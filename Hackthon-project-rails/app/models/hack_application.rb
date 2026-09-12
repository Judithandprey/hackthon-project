class HackApplication < ApplicationRecord
  STATUSES = %w[draft submitted under_review accepted waitlisted declined].freeze
  DECISIONS = %w[under_review accepted waitlisted declined].freeze
  belongs_to :user
  has_one :review, dependent: :destroy
  validates :status, inclusion: { in: STATUSES }
  validates :organization, :availability, length: { maximum: 160 }
  validates :skills, :portfolio_url, length: { maximum: 500 }
  validates :motivation, :experience, length: { maximum: 3000 }
  validate :complete_submission, unless: :draft?
  validate :safe_portfolio_url
  before_validation :strip_answers

  def draft?
    status == "draft"
  end

  def checklist
    result = {
      organization: [user.mentor? ? "Organization / current role" : "School or organization", organization.to_s.length >= 2],
      skills: [user.mentor? ? "Mentoring topics" : "Skills and interests", skills.to_s.length >= 2],
      motivation: ["Why you want to join", motivation.to_s.length >= 30],
      experience: [user.mentor? ? "Your approach to mentoring" : "An idea or project", experience.to_s.length >= 30]
    }
    result[:availability] = ["Your availability", availability.to_s.length >= 2] if user.mentor?
    result
  end

  def completeness
    (100.0 * checklist.values.count { |_, done| done } / checklist.size).round
  end

  private

  def strip_answers
    %w[organization skills motivation experience availability portfolio_url].each { |field| self[field] = self[field].to_s.strip }
  end

  def complete_submission
    checklist.each { |field, (label, done)| errors.add(field, "is incomplete (#{label})") unless done }
  end

  def safe_portfolio_url
    return if portfolio_url.blank?
    uri = URI.parse(portfolio_url)
    errors.add(:portfolio_url, "must be a full http or https URL") unless uri.is_a?(URI::HTTP) && uri.host.present?
  rescue URI::InvalidURIError
    errors.add(:portfolio_url, "must be a valid URL")
  end
end
