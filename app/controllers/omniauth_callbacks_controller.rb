class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    
    # https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
    # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
    # http://stackoverflow.com/questions/7362173/integrating-facebook-login-with-omniauth-on-rails
    # https://github.com/mkdynamic/omniauth-facebook
    # https://github.com/intridea/omniauth

    # Omniauth callback for Facebook
    def facebook
        @user           = User.from_omniauth(omniauth_hash)
        is_new_record   = @user.new_record?

        if @user.save
            flash[:success] = (is_new_record) ? "Successfully Signed Up with Facebook" : "Successfully Signed In with Facebook"
            sign_in @user
            redirect_to root_path
        else
            session["devise.facebook_data"]     = omniauth_hash
            flash[:error]                       = @user.errors.full_messages
            redirect_to new_user_registration_url
        end
    end

    # Omniauth callback for Twitter
    def twitter
        @user           = User.from_omniauth(omniauth_hash)
        is_new_record   = @user.new_record?

        if @user.save
            flash[:success] = (is_new_record) ? "Successfully Signed Up with Twitter" : "Successfully Signed In with Twitter"
            sign_in @user
            redirect_to root_path
        else
            session["devise.twitter_data"]      = omniauth_hash
            flash[:error]                       = @user.errors.full_messages
            redirect_to new_user_registration_url
        end
    end

    # Omniauth callback for google
    def google
         @user           = User.from_omniauth(omniauth_hash)
        is_new_record   = @user.new_record?

        if @user.save
            flash[:success] = (is_new_record) ? "Successfully Signed Up with Google" : "Successfully Signed In with Google"
            sign_in @user
            redirect_to root_path
        else
            session["devise.google_data"]       = omniauth_hash
            flash[:error]                       = @user.errors.full_messages
            redirect_to new_user_registration_url
        end
    end

    private

    def omniauth_hash
        request.env["omniauth.auth"]
    end
end