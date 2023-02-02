class PasswordsController < ApplicationController
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

    def edit
    end

    def update
        if @current_user.update(password_params)
            redirect_to user_profiles_path, notice: "Password updated."
        else
            render :edit
        end
    end

    private

    def password_params
        params.require(:user).permit(:password, :password_confirmation)
    end
end
