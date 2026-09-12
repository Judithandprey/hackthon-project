module Organizer
  class ReviewsController < ApplicationController
    before_action :require_login
    before_action :require_organizer

    def update
      @application = HackApplication.find(params[:application_id])
      @blind = params[:blind] == "1"
      input = params.require(:review)
      unless HackApplication::DECISIONS.include?(input[:decision])
        return redirect_to organizer_application_path(@application, blind: params[:blind]), alert: "Choose a valid decision."
      end
      @application.with_lock do
        raise ActiveRecord::StaleObjectError.new(@application, "review") unless @application.lock_version.to_s == input[:lock_version].to_s
        return head :forbidden if @application.user_id == current_user.id
        return redirect_to organizer_application_path(@application), alert: "Drafts are not ready for review." if @application.draft?
        @review = @application.review || @application.build_review
        @review.assign_attributes(input.permit(:readiness, :impact, :collaboration, :notes))
        @review.reviewer = current_user
        @review.save!
        @application.update!(status: input[:decision])
      end
      redirect_to organizer_application_path(@application, blind: params[:blind]), notice: "Review saved. The applicant can see the updated status."
    rescue ActiveRecord::StaleObjectError
      redirect_to organizer_application_path(@application, blind: params[:blind]), alert: "Another organizer changed this application. Refresh before grading."
    rescue ActiveRecord::RecordInvalid => error
      redirect_to organizer_application_path(@application, blind: params[:blind]), alert: error.record.errors.full_messages.to_sentence
    end
  end
end
