class ContactPreview <  ActionMailer::Preview
	
	# Email when user is contacting staff
	def default
		params = {name: "Bob Jones", category: "General Questions", email_from: "test@gmail.com", message: "This is my message."}
		MiscMailer.contact(params)
	end

end