class UserServicesMailer < ActionMailer::Base
	include Rails.application.routes.url_helpers

	default from: "Lendojo <staff@lendojo.com>"
	
	# Returns a mail object regarding the status update of a lender application
	def set_check_updated_mail(user_service)
		@user_service = user_service

		# Status: pending, scheduled_unconfirm, scheduled_confirmed, complete
		template 	= 'check_' + @user_service.status + '_email'
		# Change the to and subject base on @user_service status
		if @user_service.pending?
			to 		= @user_service.lender.email
			subject = "Lendojo: #{@user_service.lendee.first_name} Checked Your Service!"
		elsif @user_service.schedule_unconfirm?
			subject = "Lendojo: Please Confirm Schedule Date and Place"
			to 		= @user_service.lendee.email
		elsif @user_service.schedule_confirmed?
			to 		= @user_service.lender.email
			subject = "Lendojo: #{@user_service.lendee.first_name} Has Confirmed"
		elsif @user_service.complete?
			to 		= @user_service.lender.email
			subject = "Lendojo: Service Complete!"
		end

		# Create the mail object
		mail(to: to, subject: subject) do |format|
			format.html { render template }
		end
		
	end

end
