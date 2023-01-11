class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    helper_method :current_user, :logged_in?

    private

    def current_user
        @current_user ||= User.find_by(id: session[:user_id])
    end

    def logged_in?
        current_user
    end

    #Redirects and sends notice - used to block entries that do not belong to users /entries/entry_id
    def restrict_access
        redirect_to root_path, :notice => "Access denied"
    end
end
