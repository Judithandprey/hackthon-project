class ApplicationsController < ApplicationController
  before_action :require_login
  before_action :require_applicant

  def show
    @application = current_user.hack_application || current_user.build_hack_application
  end

  def create
    return redirect_to application_path, alert: "An application already exists. Please refresh." if current_user.hack_application
    @application = current_user.build_hack_application
    save_application
  rescue ActiveRecord::RecordNotUnique
    redirect_to application_path, alert: "This application was saved in another tab. Please refresh."
  end

  def update
    @application = current_user.hack_application
    return head :not_found unless @application
    return redirect_to application_path, alert: "Submitted applications are read-only." unless @application.draft?
    save_application
  rescue ActiveRecord::StaleObjectError
    redirect_to application_path, alert: "This application changed in another tab. Please reload before saving."
  end

  private

  def save_application
    @application.assign_attributes(params.require(:hack_application).permit(:organization, :skills, :motivation, :experience, :availability, :portfolio_url, :lock_version))
    if params[:intent] == "submit"
      @application.status = "submitted"
      @application.submitted_at = Time.current
    end
    if @application.save
      redirect_to application_path, notice: @application.draft? ? "Draft saved. You can return to it anytime." : "Application submitted. Follow your status here."
    else
      # Failed submission remains editable; no invalid state was written to the database.
      @application.status = "draft"
      render :show, status: :unprocessable_entity
    end
  end
end
