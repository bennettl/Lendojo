class UserServicesPreview <  ActionMailer::Preview
	# Email when a user service 'check' status is set to 'complete'
	def check_complete
		# Picked a random 'check' user service and temporary set it's status to complete
		user_service 		= UserService.find_by(relationship_type: 'check')
		user_service.status = 'complete'
		UserServicesMailer.check_updated(user_service)
	end
	
	# Email when a user service 'check' status is set to 'pending'
	def check_pending
		# Picked a random 'check' user service and temporary set it's status to pending
		user_service 		= UserService.find_by(relationship_type: 'check')
		user_service.status = 'complete'
		UserServicesMailer.check_updated(user_service)
	end
	
	# Email when a user service 'check' status is set to 'scheduled_confirmed'
	def check_schedule_confirmed
		# Picked a random 'check' user service and temporary set it's status to schedule_confirmed
		user_service 		= UserService.find_by(relationship_type: 'check')
		user_service.date 	= Time.now
		user_service.status = 'schedule_confirmed'
		UserServicesMailer.check_updated(user_service)
	end

	# Email when a user service 'check' status is set to 'scheduled_unconfirmed'
	def check_schedule_unconfirmed
		# Picked a random 'check' user service and temporary set it's status to scheduled_unconfirmed
		user_service 		= UserService.find_by(relationship_type: 'check')
		user_service.date 	= Time.now
		user_service.status = 'schedule_unconfirm'
		UserServicesMailer.check_updated(user_service)
	end
end
