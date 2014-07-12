class AdminMailer < ActionMailer::Base
	
	# Use application_mail.html.erb
	layout 'application_mailer'

	# Automatically inject css styles
	include Roadie::Rails::Automatic

  # default from: "from@example.com"
end
