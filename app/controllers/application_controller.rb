class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	# Don't worry about CSRF attacks in development
	if Rails.env.development?
		protect_from_forgery with: :null_session	
	else
		protect_from_forgery with: :exception
	end

	######## DEBUGGIN ####

	# Set up http authentication
	USERS = { "lender" => "lendee" }

	before_filter :authenticate

	def authenticate
	  authenticate_or_request_with_http_digest("Application") do |name|
	    USERS[name]
	  end
	end

	def current_user
	  User.first
	end

	def signed_in?
		true
	end


end
