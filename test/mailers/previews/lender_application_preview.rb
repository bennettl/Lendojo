class LenderApplicationPreview <  ActionMailer::Preview

	# Email when lender application status is set to 'approved'
	def approved
		# Picked a random lender application and temporary set it's status to approve
		lender_app 			= LenderApplication.first
		lender_app.status 	= 'approved'
		LenderApplicationsMailer.updated(lender_app)
	end

	# Email when lender application is created
	def created
			# Picked a random lender application and temporary set it's status to pending
		lender_app 			= LenderApplication.first
		lender_app.status 	= 'pending'
		LenderApplicationsMailer.created(lender_app)
	end

	# Email when lender application status is set to 'denied'
	def denied
		# Picked a random lender application and temporary set it's status to denied
		lender_app 			= LenderApplication.first
		lender_app.status 	= 'denied'
		LenderApplicationsMailer.updated(lender_app)
	
	end

end