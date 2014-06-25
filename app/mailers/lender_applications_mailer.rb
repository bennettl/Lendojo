class LenderApplicationsMailer < ActionMailer::Base
	default from: "Lendojo <staff@lendojo.com>"

	# Returns a mail object regarding the creation of an lender app
	def set_created_mail(lenderApp)
		admin_email = 'bennettl@usc.edu'
		@lenderApp 	= lenderApp
		subject 	= 'Lendojo: New Lender Application'

		mail(to: admin_email, subject: subject) do |format|
			format.html { render 'created_email' }
		end
	end

	# Returns a mail object regarding the status update of a lender application
	def set_updated_mail(lenderApp, user)
		@user 	 	= user
		@lenderApp 	= lenderApp
		template 	= @lenderApp.status + '_email'

		# Change the subject base on @lenderApp status
		case @lenderApp.status
			when 'approved'
				subject = "Lendojo: Lender Application Approved!"
			when 'denied'
				subject = "Lendojo: Lender Application Denied"
		end

		mail(to: @user.email, subject: subject) do |format|
			format.html { render template }
		end
	end
end
