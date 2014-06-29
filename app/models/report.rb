class Report < ActiveRecord::Base
	
	################################## ASSOCIATION ##################################

	belongs_to :author, class_name: 'User', foreign_key: 'author_id' # use lender_id instead of user_id

	# (Polymorphic) association, because the object being reported can be user/product/services
	belongs_to :reportable, polymorphic: true

	################################## ENUMS ##################################

	enum status: [ :pending, :active, :resolved]
	enum reason: ["Inappropriate Content", "Fraud", "Misleading Content", "Spam", "Other"]
	enum action: ["No Action", "Warn", "Suspend", "Ban" ]

	################################## VALIDATION ##################################

	validates :summary, presence: true

	################################## REPORTS ##################################

	# Searches members base on filter data, return all members if no filter_data is present
	# Ex. filter_data = { locations: ['San Francisco'], prices: ['$$', '$$$'], belts: [], keywords: [] }
	def self.search(filter_data)
		if !filter_data.empty?
			# Parameters
			query 	= [] # init array

			# Status: Push individual status queries to array, then join with 'OR'
			unless filter_data[:statuses].nil? || filter_data[:statuses].empty?
				query_status = [] # init subarray
				filter_data[:statuses].each do |s|
					query_status.push("status = '#{s}'")
				end
				# Join subqueries with 'OR' and wrap entire query string with parenthesis
				query_status = query_status.join(' OR ').insert(0, '(').insert(-1, ')')
			end  

			# Status: Push individual types queries to array, then join with 'OR'
			unless filter_data[:reportable_types].nil? || filter_data[:reportable_types].empty?
				query_type = [] # init subarray
				filter_data[:reportable_types].each do |t|
					query_type.push("reportable_type = '#{t}'")
				end
				# Join subqueries with 'OR' and wrap entire query string with parenthesis
				query_type = query_type.join(' OR ').insert(0, '(').insert(-1, ')')
			end  


			# Place all subqueries in an array
			query = [query_status, query_type]
			 # Remove nil queries
			query.reject! {|q| q.nil? }
			# Where combines all queries with 'AND'
			self.where(query.join(' AND '))
		else
			# all users
			self.all
		end
	end

end
