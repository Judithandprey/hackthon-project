class UsersController < ApplicationController
  def new
    @user = User.new(role: "hacker")
  end

  def create
    @user = User.new(params.require(:user).permit(:name, :email, :password, :password_confirmation, :role))
    unless LoginAttempt.allowed?(@user.email)
      @user.errors.add(:base, "Too many attempts. Please try again in 15 minutes.")
      return render :new, status: :too_many_requests
    end
    if @user.organizer?
      expected = ENV.fetch("ORGANIZER_INVITE_CODE", "")
      supplied = params.dig(:user, :invite_code).to_s
      unless expected.length >= 32 && ActiveSupport::SecurityUtils.secure_compare(expected, supplied)
        @user.errors.add(:base, "The organizer invitation code is not valid.")
        return render :new, status: :unprocessable_entity
      end
    end
    if @user.save
      start_session(@user)
      redirect_to home_for(@user), notice: "Welcome! Your account is ready."
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique
    @user.errors.add(:email, "has already been taken")
    render :new, status: :unprocessable_entity
  end
end
