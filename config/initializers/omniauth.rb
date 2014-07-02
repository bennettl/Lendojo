Rails.application.config.middleware.use OmniAuth::Builder do
	# Keys and secrets
	ENV['TWITTER_KEY'] 				= 'kdftnRXOliUcB6VHCvUscpLol'
	ENV['TWITTER_SECRET'] 			= 'qq86ZUIN7aE9iLOl5TgkR0nioTqLNQlr9tyX0BUWmV0MZpMDFB'
	ENV['FACEBOOK_KEY'] 			= '250307078491268'
	ENV['FACEBOOK_SECRET'] 			= '81b5013d7c38274f7ebc651644289a7b'
	ENV["GOOGLE_CLIENT_ID"] 		= '269634153403-31jb571pldgv89dm99u9lusqt2hmfnkb.apps.googleusercontent.com'
	ENV["GOOGLE_CLIENT_SECRET"] 	= 'UtA0dqE7pfbtd5IorEg51UjE'
	# Providers
	provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
	provider :facebook, ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET'], scope:"email,user_birthday,user_location", image_size: "large", display: "popup"
	provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"]
end

# https://github.com/intridea/omniauth/wiki/Auth-Hash-Schema
# https://github.com/plataformatec/devise/wiki/OmniAuth:-Overview
# http://stackoverflow.com/questions/7362173/integrating-facebook-login-with-omniauth-on-rails
# https://github.com/mkdynamic/omniauth-facebook
# https://github.com/intridea/omniauth
# http://railscasts.com/episodes/236-omniauth-part-2