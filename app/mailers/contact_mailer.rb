class ContactMailer < ActionMailer::Base
	default to: "bennettlee908@gmail.com"

	# Returns a contact us mail object with the params appended to it
	def set_mail(params)
		name 			= params[:name]
		category		= params[:category] #General Questions, Technical Questions, Suggestions, Business Inquiries, Media, Other
		to				=  "bennettlee908@gmail.com"
		from 			= name + "<" + params[:email_from] + ">"
		message 		= params[:message]
		message_html 	= "Lendojo Contact Form: <br /><br /> <b>Category:</b> #{category} <b>Message</b>: #{message}" 

		mail(to: to, from: from, subject: 'Lendojo Contact Form') do |format|
			format.html { render html:  message_html }
		end
	end
end