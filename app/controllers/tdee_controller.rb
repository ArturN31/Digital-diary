class TdeeController < ApplicationController
  before_action :authenticate 

  #User authentication - only logged in user can access the entries view
  def authenticate
    unless logged_in?
      respond_to do |format|
        format.html { redirect_to "/login", notice: "You must be logged in to access this section" }
        format.json { head :no_content }
      end
    end
  end

  def index
  end
end
