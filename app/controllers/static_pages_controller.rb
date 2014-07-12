class StaticPagesController < ApplicationController

	# Different home page for signed in users
	def home
		if user_signed_in?
			redirect_to services_path
		else
			render 'home'
		end
	end

	# Send the contact us message and redirect user
	def contact_form_submit
		MiscMailer.contact(params).deliver
		flash[:success] = "Thanks for your message! We will contact you as soon as possible."
		redirect_to :back
	end
	
end
