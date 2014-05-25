module SessionsHelper

	# Sign in user by creating a new reuser token, store it in cookie and encrpyted version on database
	def sign_in(user)
		reuser_token 						= User.new_reuser_token
		cookies.permanent[:reuser_token] 	= reuser_token
		user.update_attribute(:reuser_token, User.encrypt(reuser_token))
		self.current_user = user
	end

	# Is the user signed in? Calling this function within a view, or other controllers.
	def signed_in?
		!self.current_user.nil?
	end

	# Sign user out by replacing user's reuser token in dabatse with a random one and delete reuser token in cookie
	def sign_out
		# Make a random reuser token in case user cookie is every stolen
		randomReuserToken = User.new_reuser_token
		current_user.update_attribute(:reuser_token, User.encrypt(randomReuserToken))
		# Delete reuser token from cookies and set user to nil
		cookies.delete(:reuser_token)
		self.current_user = nil
	
	end

	# Set instance variable () to user
	def current_user=(user)
		@current_user = user
	end

	# When retriving current user, grab session token from cookie and see if user exists in database
	def current_user
		encrypted_reuser_token = User.encrypt(cookies[:reuser_token])
		@current_user ||= User.find_by(reuser_token: encrypted_reuser_token) #only calls find_by when @current_user is nil
	end

	# See if current user is the same as user
	def current_user?(user)
		current_user == user
	end

	 # Redirects non signed in user with notice assigned to flash[:notice]
    def sign_in_user
        # If user is not signed in, store the location and redirect to sign in page
        unless signed_in?
            store_location
            redirect_to(signin_url, notice: 'Please sign in yo')
        end
    end

	# Friendly forwarding

	# Redirect the user back to the sessios[:return_to] or default
	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	# Store location of url in session[:return_to]
	def store_location
		# Only store URL if its a get request
		session[:return_to] = request.url if request.get?
	end
end

































