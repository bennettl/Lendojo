class UserStatusPreview <  ActionMailer::Preview
	# Email when user status is set to 'active'
	def active
		# Pick a random user and temporary set his status to 'active'
		user = User.first
		user.status = 'active'
		UserStatusMailer.set_mail(user)
	end
	
	# Email when user status is set to 'banned'
	def banned
		# Pick a random user and temporary set his status to 'banned'
		user = User.first
		user.status = 'banned'
		UserStatusMailer.set_mail(user)
	end

	# Email when user status is set to 'inactive'
	def inactive
		# Pick a random user and temporary set his status to 'inactive'
		user = User.first
		user.status = 'inactive'
		UserStatusMailer.set_mail(user)
	end

	# Email when user status is set to 'suspended'
	def suspended
		# Pick a random user and temporary set his status to 'suspended'
		user = User.first
		user.status = 'suspended'
		UserStatusMailer.set_mail(user)
	end

	# Email when user status is set to 'warned'
	def warned
		# Pick a random user and temporary set his status to 'warned'
		user = User.first
		user.status = 'warned'
		UserStatusMailer.set_mail(user)
	end
end