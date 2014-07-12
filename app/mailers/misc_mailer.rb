class MiscMailer < ActionMailer::Base
	# Use application_mail.html.erb
	layout 'application_mailer'

	# Automatically inject css styles
	include Roadie::Rails::Mailer

	default to: "bennettlee908@gmail.com"

	# Mail when user contacts Lendojo staff
	def contact(params)
		@name 			= params[:name]
		@category		= params[:category] #General Questions, Technical Questions, Suggestions, Business Inquiries, Media, Other
		to				=  "bennettlee908@gmail.com"
		from 			= @name + "<" + params[:email_from] + ">"
		@message 		= params[:message]

		mail(to: to, from: from, subject: 'Lenodjo: Contact') do |format|
			format.html { render 'contact' }
		end

	end
end