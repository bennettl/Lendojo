module ApplicationHelper

	# Returns the navigation link with the current class
	def nav_link(link_text, link_path)
		class_name = current_page?(link_path) ? 'active nav-link' : 'nav-link'
		link_to link_text, link_path, class: class_name
	end


	# Returns an arrary of US states
	def us_states
	    [ ['AL'], ['AK'], ['AZ'], ['AR'], ['CA'], ['CO'], ['CT'], ['DE'], ['DC'], ['FL'], ['GA'], ['HI'], ['ID'], ['IL'], ['IN'], ['IA'], ['KS'], ['KY'], ['LA'], ['ME'], ['MD'], ['MA'], ['MI'], ['MN'], ['MS'], ['MO'], ['MT'], ['NE'], ['NV'], ['NH'], ['NJ'], ['NM'], ['NY'], ['NC'], ['ND'], ['OH'], ['OK'], ['OR'], ['PA'], ['PR'], ['RI'], ['SC'], ['SD'], ['TN'], ['TX'], ['UT'], ['VT'], ['VA'], ['WA'], ['WV'], ['WI'], ['WY']
	    ]
	end
end