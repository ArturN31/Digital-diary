class HomeController < ApplicationController#
  def index
    #delays page load on mobiles and tablets - allows animatino to complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end
    
    if logged_in?
      @entries = Entry.where(user_id: current_user.id).where("created_at >= ?", Date.today.at_beginning_of_week).reverse.each.group_by(&:day)
    end
  end
end