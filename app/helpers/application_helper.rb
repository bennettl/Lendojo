module ApplicationHelper

	# Returns the navigation link with the current class
	def nav_link(link_text, link_path)
		class_name = current_page?(link_path) ? 'active nav-link' : 'nav-link'
		link_to link_text, link_path, class: class_name
	end

	# Is the current user an administrator?
	def is_admin?
		signed_in? && current_user.status == 'admin'
	end
end