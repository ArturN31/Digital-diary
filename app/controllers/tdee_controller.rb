class TdeeController < ApplicationController
  before_action :authenticate 

  #User authentication - only logged in user can access the entries view
  def authenticate
    redirect_to(new_session_path) unless logged_in?
  end

  def index
  end
end
