class UsersController < ApplicationController
    before_action :set_user, only: %i[ new update ]

    def new
        #delays page load on mobiles and tablets - allows animatino to complete and loads the page
        if device == "tablet" || device == "mobile"
            sleep 0.385 
        end
        @user = User.new
    end
 
    def create
        @user = User.new(user_params)

        if @user.save
            redirect_to root_url, notice: 'Thank you for signing up and remember to create your profile upon logging in!'
        else
            render :new
        end
    end

    private
    
    def user_params
        params.require(:user).permit(:name, :email, :password)
    end
end
