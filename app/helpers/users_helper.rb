module UsersHelper

	# Returns a user image with options
	def user_img(user)
		html = '<div class="imageContainer">' +
					image_tag(user.avatar.url) +
					'<div id="options">' +
						link_to('', edit_user_path(user), class: "glyphicon glyphicon-pencil edit") +
						link_to('', '#', class: "glyphicon glyphicon-flag flag") +
					'</div>
				</div>'
		html.html_safe
	end
end
