class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  helper_method :current_user
  before_action { response.headers["Cache-Control"] = "no-store" }

  private

  def current_login_session
    return @current_login_session if defined?(@current_login_session)
    @current_login_session = LoginSession.for_token(cookies.encrypted[:login_token])
  end

  def current_user
    current_login_session&.user
  end

  def require_login
    redirect_to sign_in_path, alert: "Please sign in to continue." unless current_user
  end

  def require_applicant
    head :forbidden if current_user&.organizer?
  end

  def require_organizer
    head :forbidden unless current_user&.organizer?
  end

  def start_session(user)
    current_login_session&.destroy!
    reset_session
    cookies.encrypted[:login_token] = { value: LoginSession.issue!(user), expires: 7.days.from_now, httponly: true, same_site: :lax, secure: Rails.env.production? }
  end

  def home_for(user)
    user.organizer? ? organizer_applications_path : application_path
  end
end
