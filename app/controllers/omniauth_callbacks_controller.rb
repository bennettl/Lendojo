class OmniauthCallbacksController < Devise::OmniauthCallbacksController

    # Omniauth callback for Facebook
    def facebook
        process_omniauth_callback('facebook')
    end

    # Omniauth callback for Twitter
    def twitter
       process_omniauth_callback('twitter')
    end

    # Omniauth callback for google
    def google
       process_omniauth_callback('google')
    end

    private

    # Process the omniauth callback by creating/retriving user, and signing the user in or redirecting to registration page if there is an error
    def process_omniauth_callback(provider)
        @user           = User.from_omniauth(omniauth_hash)
        is_new_record   = @user.new_record?

        # If user is sucessfully saved, display the appropriate message, sign user in, and redirect to home page
        if @user.save
            flash[:success] = (is_new_record) ? "Successfully Signed Up with #{provider.titleize}" : "Successfully Signed In with #{provider.titleize}"
            sign_in @user
            redirect_to root_path
        else
            session["devise.#{provider}_data"]      = omniauth_hash
            flash[:error]                           = @user.errors.full_messages
            redirect_to new_user_registration_path
        end 
    end

    # Returns data provided by omniauth
    def omniauth_hash
        request.env["omniauth.auth"]
    end

    # Addtional Resources
    # https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
    # https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
    # http://stackoverflow.com/questions/7362173/integrating-facebook-login-with-omniauth-on-rails
    # https://github.com/mkdynamic/omniauth-facebook
    # https://github.com/intridea/omniauth
end