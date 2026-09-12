class Review < ApplicationRecord
  belongs_to :hack_application
  belongs_to :reviewer, class_name: "User"
  validates :readiness, :impact, :collaboration, inclusion: { in: 1..5 }, numericality: { only_integer: true }
  validates :notes, length: { maximum: 3000 }

  def total
    readiness.to_i + impact.to_i + collaboration.to_i
  end
end
