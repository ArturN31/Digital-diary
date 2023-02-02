class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    helper_method :current_user, :logged_in?, :user_profile, :profile_exists?, :device

    private

    def current_user
        @current_user ||= User.find_by(id: session[:user_id])
    end

    def user_profile
        @user_profile ||= UserProfile.find_by(user_id: current_user.id)
    end

    def logged_in?
        current_user
    end

    def profile_exists?
        user_profile
    end

    #Redirects and sends notice - used to block entries that do not belong to users /entries/entry_id
    def restrict_access
        redirect_to root_path, :notice => "Access denied"
    end

    #Returns device type
    def device
        agent = request.user_agent
        return "tablet" if agent =~ /(tablet|ipad)|(android(?!.*mobile))/i
        return "mobile" if agent =~ /Mobile/
        return "desktop"
    end
end
