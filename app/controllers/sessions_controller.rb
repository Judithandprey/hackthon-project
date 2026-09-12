class SessionsController < ApplicationController
  def new; end

  def create
    email = params[:email].to_s.strip.downcase
    unless LoginAttempt.allowed?(email)
      flash.now[:alert] = "Too many attempts. Please try again in 15 minutes."
      return render :new, status: :too_many_requests
    end
    user = User.authenticate_by(email: email, password: params[:password].to_s)
    if user
      start_session(user)
      redirect_to home_for(user), notice: "Welcome back."
    else
      flash.now[:alert] = "Email or password is incorrect."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    current_login_session&.destroy!
    reset_session
    cookies.delete(:login_token)
    redirect_to root_path, notice: "You have signed out.", status: :see_other
  end
end
