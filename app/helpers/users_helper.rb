module UsersHelper

	# Returns a user image with options
	def user_img(user)
		html = '<div class="imageContainer">' +
					image_tag(user.main_img.url) +
					'<div id="options">' +
						link_to('', edit_user_path(user), class: "glyphicon glyphicon-pencil edit") +
						link_to('', '#', class: "glyphicon glyphicon-flag flag") +
					'</div>
				</div>'
		html.html_safe
	end

	# Use for edit and new
	def row(label, input)
		"<div class=\"group col-xs-12\">
			<div class=\"col-md-4 col-sm-5\">
				#{label}
			</div>
			<div class=\"col-md-8 col-sm-7\">
				#{input}
			</div>
		</div>".html_safe
	end
end
