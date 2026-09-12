module Organizer
  class ApplicationsController < ApplicationController
    before_action :require_login
    before_action :require_organizer

    def index
      @blind = params[:blind] == "1"
      @counts = HackApplication.group(:status).count
      @applications = HackApplication.includes(:user, :review).joins(:user).order(updated_at: :desc)
      @applications = @applications.where(status: params[:status]) if HackApplication::STATUSES.include?(params[:status])
      @applications = @applications.where(users: { role: params[:role] }) if %w[hacker mentor].include?(params[:role])
      if params[:q].present? && !@blind
        query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:q].to_s.downcase.first(128))}%"
        @applications = @applications.where("LOWER(users.name) LIKE ? OR LOWER(users.email) LIKE ?", query, query)
      end
    end

    def show
      @blind = params[:blind] == "1"
      @application = HackApplication.includes(:user, :review).find(params[:id])
      @review = @application.review || @application.build_review
    end
  end
end
