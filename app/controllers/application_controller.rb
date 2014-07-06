class ApplicationController < ActionController::Base
	
	# Prevent CSRF attacks by raising an exception. For APIs, you may want to use :null_session instead.
	# Don't worry about CSRF attacks in development
	if Rails.env.development?
		protect_from_forgery with: :null_session	
	else
		protect_from_forgery with: :exception
	end

	# If user signup isn't complete, redirect to finish_signup_path
	def ensure_signup_complete
	    # Ensure we don't go into an infinite loop
	    return if action_name == 'finish_signup'
	    
	    # Redirect to the 'finish_signup' page if the user email is blank
	    if current_user.email.nil? || current_user.email.empty?
			redirect_to finish_signup_user_path(current_user)
		end
	end

	########################### DEBUGGING PURPOSES ##########################

	# Set up http authentication
	# USERS = { "lender" => "lendee" }
	# before_filter :authenticate

	# def authenticate
	#   authenticate_or_request_with_http_digest("Application") do |name|
	#     USERS[name]
	#   end
	# end

	# def current_user
	#   User.first
	# end

	# def signed_in?
	# 	true
	# end


end
