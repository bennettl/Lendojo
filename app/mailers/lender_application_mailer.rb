class LenderApplicationMailer < ActionMailer::Base
	default from: "Lendojo <staff@lendojo.com>"

	# Returns a  mail object with the user information appended to it
	def set_mail(lenderApp, user)
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
