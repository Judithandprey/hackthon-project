class HomeController < ApplicationController
  def index
    redirect_to home_for(current_user) if current_user
  end
end
