module ApplicationHelper

	# Returns the navigation link with the current class
	def nav_link(link_text, link_path)
		class_name = current_page?(link_path) ? 'active nav-link' : 'nav-link'
		link_to link_text, link_path, class: class_name
	end

	# Returns an arrary of US states
	def us_states_initials
	    us_states_hash.values
	end

	# Return state initials from the name of the state
	def us_state_initials_from_name(name)
		# Replace space with underscore in order to access hash
		name.gsub!(/ /, '_')
		us_states_hash[name]
	end

	private 

	def us_states_hash
 		hash = { Alabama: 'AL', Alaska: 'AK', Arizona: 'AZ', Arkansas: 'AR', California: 'CA', Colorado: 'CO', Connecticut: 'CT', Delaware: 'DE', District_of_Columbia: 'DC', Florida: 'FL', Georgia: 'GA', Hawaii: 'HI', Idaho: 'ID', Illinois: 'IL', Indiana: 'IN', Iowa: 'IA', Kansas: 'KS', Kentucky: 'KY', Louisiana: 'LA', Maine: 'ME', Maryland: 'MD', Massachusetts: 'MA', Michigan: 'MI', Minnesota: 'MN', Mississippi: 'MS', Missouri: 'MO', Montana: 'MT', Nebraska: 'NE', Nevada: 'NV', New_Hampshire: 'NH', New_Jersey: 'NJ', New_Mexico: 'NM', New_York: 'NY', North_Carolina: 'NC', North_Dakota: 'ND', Ohio: 'OH', Oklahoma: 'OK', Oregon: 'OR', Pennsylvania: 'PA', Puerto_Rico: 'PR', Rhode_Island: 'RI', South_Carolina: 'SC', South_Dakota: 'SD', Tennessee: 'TN', Texas: 'TX', Utah: 'UT', Vermont: 'VT', Virginia: 'VA', Washington: 'WA', West_Virginia: 'WV', Wisconsin: 'WI', Wyoming: 'WY' }
 		# Doesn't matter if key is symbol or string
 		hash.with_indifferent_access
	end
end