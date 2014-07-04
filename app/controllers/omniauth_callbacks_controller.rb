class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Omniauth callback for Facebook
    def facebook
        # You need to implement the method below in your model (e.g. app/models/user.rb)
        # render 'static_pages/home'
        @user       = User.from_omniauth(omniauth_hash)
        if @user.persisted?
            flash[:success] = "Successfully signed up with Facebook account."
            sign_in_and_redirect @user
        else
            session["devise.facebook_data"] = omniauth_hash
            # redirect_to new_user_registration_url
            render 'devise/registrations/new'
        end
    end

    # Omniauth callback for Twitter
    def twitter
        @user       = User.from_omniauth(omniauth_hash)
        @omniauth = omniauth_hash
        render 'devise/registrations/new'
    end

    # Omniauth callback for google
    def google_oauth2
        @user       = User.from_omniauth(omniauth_hash)
        @omniauth = omniauth_hash
        render 'devise/registrations/new'
    end

    private

    def omniauth_hash
        request.env["omniauth.auth"]
    end
end