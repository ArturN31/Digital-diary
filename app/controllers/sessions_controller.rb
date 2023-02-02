class SessionsController < ApplicationController
  def new
    #delays page load on mobiles and tablets - allows animatino to complete and loads the page
    if device == "tablet" || device == "mobile"
      sleep 0.385 
    end
  end

  def create
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to root_path, notice: 'Logged in!'
    else
      flash.now.alert = 'Email or password is invalid'
      render :new
    end
  end

  def destroy
    session.delete(:user_id)
    redirect_to root_path, notice: 'Logged out!'
  end
end
