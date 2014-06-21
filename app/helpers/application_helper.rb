module ApplicationHelper

	# Returns the navigation link with the current class
	def nav_link(link_text, link_path)
		class_name = current_page?(link_path) ? 'current' : ''
		link_to link_text, link_path, class: class_name
	end

	# Returns a dashboard widget for index pages only viewable by admin
	# Accepts title as the title of dashboard, data as a hash of <th>key</th> and <td>value</td>
	def dashboard_widget(title, data)
		html= '<div class="title pull-left">' + title + '</div>
				<table class="indexListDashboard table">'
		
		data.each do |key, value|
			html += "<tr>
						<th>#{key}</th>
						<td>#{value}</td>
					</tr>"
		end
		
		html += '</table>'

		html.html_safe # return the html
	end
end