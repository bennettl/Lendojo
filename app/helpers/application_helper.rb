module ApplicationHelper
	# Returns the navigation link with the current class
	def nav_link(link_text, link_path)
		class_name = current_page?(link_path) ? 'current' : ''
		link_to link_text, link_path, class: class_name
	end

	def service_img (service)

		html = '<div class="imageContainer">' +
					image_tag(service.main_img.url) +
					'<div id="options">' +
						link_to('', '#', class: "glyphicon glyphicon-list list") +
						link_to('', edit_service_path(service), class: "glyphicon glyphicon-pushpin pin") +
						link_to('', '#', class: "glyphicon glyphicon-pencil edit") +
						link_to('', '#', class: "glyphicon glyphicon-flag flag") +
					'</div>
				</div>'

		html.html_safe
	end

end
