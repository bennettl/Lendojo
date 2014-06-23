class UserStatusMailer < ActionMailer::Base
	default from: "Lendojo <staff@lendojo.com>"
	# Use whenver the user status changes ('active', 'warn', 'suspend', ban') or when new user is created ('inactive')

	# Returns a  mail object with the user information appended to it
	def set_mail(user)
		@user 	 = user
		template = @user.status + '_email'

		case @user.status
			when 'inactive'
				subject = "Lendojo: Activate Your Account"
			when 'active'
				subject = "Lendojo: Your Account Has Been Activated"
			when 'warned'
				subject = "Lendojo: Warning"
			when 'suspended'
				subject = "Lendojo: Your Account Has Been Suspended"
			when 'banned'
				subject = "Lendojo: Your Account Has Been Banned"
		end

		mail(to: @user.email, subject: subject) do |format|
			format.html { render template }
		end
	end

end
