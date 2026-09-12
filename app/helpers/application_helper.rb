module ApplicationHelper
  def status_label(status)
    { "under_review" => "In review" }.fetch(status, status.humanize)
  end

  def pacific_time(time)
    time&.in_time_zone&.strftime("%b %-d, %Y · %-I:%M %p %Z")
  end
end
