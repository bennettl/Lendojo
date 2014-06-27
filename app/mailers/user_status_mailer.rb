class UserStatusMailer < ActionMailer::Base
	default from: "Lendojo <staff@lendojo.com>"
	# Use whenver the user status changes ('active', 'warn', 'suspend', ban') or when new user is created ('inactive')

	# Returns a  mail object with the user information appended to it
	def set_mail(user)
		@user 	 = user
		template = @user.status + '_email'

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
