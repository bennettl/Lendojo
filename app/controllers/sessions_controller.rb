class SessionsController < ApplicationController
	# Displays signin form
	def new

	end
	
	# SignIn form from 'new' passes in params[:session]
	# Create a new session
	def create
		# Get Email and Password from params[:session]
		user 		= User.find_by(email: params[:session][:email].downcase)
		password 	= params[:session][:password]
	
		# Check for valid username and password		
		if (user && user.authenticate(password))
			# Sign user in and redirect user to profile page
			sign_in(user)
		    # Redirect the user back to a page previously saved in store_location if it exists
            redirect_back_or(user)
   		else
			# Display error message
			flash.now[:error] = 'This is not working'
			render 'new'
		end
	end

	# Sign user out and redirect to root_url
	def destroy
		sign_out
		redirect_to(root_url) 
	end
end
