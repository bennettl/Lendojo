class UserStatusMailer < ActionMailer::Base
	# Use application_mail.html.erb
	layout 'application_mailer'

	# Automatically inject css styles
	include Roadie::Rails::Automatic

	default from: "Lendojo <staff@lendojo.com>"

	# Mail when a user status is updated
	def set_mail(user)
		@user 	 = user
		template = @user.status

		case @user.status
			when User.statuses[:inactive]
				subject = "Lendojo: Activate Your Account"
			when User.statuses[:active]
				subject = "Lendojo: Your Account Has Been Activated"
			when User.statuses[:warned]
				subject = "Lendojo: Warning"
			when User.statuses[:suspended]
				subject = "Lendojo: Your Account Has Been Suspended"
			when User.statuses[:banned]
				subject = "Lendojo: Your Account Has Been Banned"
		end

		mail(to: @user.email, subject: subject) do |format|
			format.html { render template }
		end
	end

end
