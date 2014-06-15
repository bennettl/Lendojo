module ApplicationHelper
	# Returns the navigation link with the current class
	def nav_link(link_text, link_path)
		class_name = current_page?(link_path) ? 'current' : ''
		link_to link_text, link_path, class: class_name
	end

end
