class ArchivesController < ApplicationController
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
    #delays page load on mobiles and tablets - allows animatino to complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end
    
    #Used to get user specific entries order them by created_at and meal_type, then paginated per 10 entries a page
    @entries = Entry.where(user_id: current_user.id).order(created_at: :desc, food_meal_type: :desc).page(params[:page]).per(10)
    

  end
end
