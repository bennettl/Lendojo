class StaticPagesController < ApplicationController

	# Send the contact us message and redirect user
	def contact_form_submit
		ContactMailer.set_mail(params).deliver
		flash[:success] = "Thanks for your message! We will contact you as soon as possible."
		redirect_to :back
	end
	
end
