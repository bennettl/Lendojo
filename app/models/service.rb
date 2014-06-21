class Service < ActiveRecord::Base

	################################## ASSOCIATIONS ##################################

	belongs_to :lender, class_name: 'User', foreign_key: 'lender_id' # use lender_id instead of user_id
    has_many :user_services, foreign_key: "service_id", dependent: :destroy

	# Items are services/products user added  to checklist
	# has_many :past_customers, through: :checklist_items, source: :user, dependent: :destroy
	# Pins are services 
	# has_many :interested_customers, through: :user_services, source: :user

	# Polymorpic associations 
	has_many :reports_received, class_name: "Report", as: :reportable

	# Attachment 
	has_attached_file :main_img,
						:styles => { :medium => "500x500>", :thumb => "150x150>" }, 
						:default_url => "/images/services/main_img/:style/missing.png", 
						:url => "/assets/services/:id/:style/:basename.:extension",
						:path => ":rails_root/public/assets/services/:id/:style/:basename.:extension"
	validates_attachment_content_type :main_img, :content_type => /\Aimage\/.*\Z/

	################################## VALIDATION ##################################

	validates :title, presence: true
	validates :headline, presence: true
	validates :summary, presence: true
	validates :location, presence: true
	validates :price, presence: true
	validates :category, presence: true


	# Returns the title use for reports
	def report_title
		self.title
	end

	# Price Key
	# $ 		|		Inexpensive 	|	 < 15
	# $$ 		|		Moderate 		|	 < 50
	# $$$		|		 Pricey			|	 < 100
	# $$$$ 		| 		High end		|	 > 100

	# Input symbol ('$','$$','$$$', '$$$$'), returns an 'range' array with min/max
	def self.price_range(symbol)
		range = {} # init hash

		case symbol
			when '$'
				range[:min] = 0
				range[:max] = 20
			when '$$'
				range[:min] = 21
				range[:max] = 80
			when '$$$'
				range[:min] = 81
				range[:max] = 150
			when '$$$$'
				range[:min] = 151
				range[:max] = 10000
		end

		range # return range
	end

	# Input price ('50', '100', '200'), returns symbol ('$','$$','$$$', '$$$$')
	def self.price_to_symbol(price)
		if (price < 21)
			"$"
		elsif price < 81
			"$$"
		elsif price < 151
			"$$$"
		else
			"$$$$"
		end
	end

	# Searches members base on filter data, return all members if no filter_data is present
	# Ex. filter_data = { locations: ['San Francisco'], prices: ['$$', '$$$'], belts: [], keywords: [] }
	def self.search(filter_data)
		if !filter_data.empty?
			# Parameters
			query 	= [] # init array
			like 	= Rails.env.development? ? 'LIKE' : 'ILIKE' ; #case insensitive for postgres

			# Location: Push individual location queries to array, then join with 'OR'
			unless filter_data[:locations].nil? || filter_data[:locations].empty?
				query_location = [] # init subarray
				filter_data[:locations].each do |l|
					query_location.push("services.location = '#{l}'")
				end
				# Join subqueries with 'OR' and wrap entire query string with parenthesis
				query_location = query_location.join(' OR ').insert(0, '(').insert(-1, ')')
			end  


			# Price: Grab the price range base on the price symbol, push individual price queries to array, then join with 'OR'
			unless filter_data[:prices].nil? || filter_data[:prices].empty?
				query_price = [] # init subarray
				filter_data[:prices].each do |price_symbol|
					range = Service.price_range(price_symbol)
					query_price.push("(services.price >= '#{range[:min]}' AND services.price <= '#{range[:max]}')")
				end
				# Join sub-queries with 'OR' and wrap entire query string with parenthesis
				query_price = query_price.join(' OR ').insert(0, '(').insert(-1, ')')
			end

			# Rank: Push individual belt queries to array, then join with 'OR'
			unless filter_data[:belts].nil? || filter_data[:belts].empty?
				query_belt = [] # init subarray
				filter_data[:belts].each do |r|
					query_belt.push("users.belt = '#{r}'")
				end
				# Join sub-queries with 'OR' and wrap entire query string with parenthesis
				query_belt = query_belt.join(' OR ').insert(0, '(').insert(-1, ')')
			end

			# Keyword: Push individual queries to array, then join with 'OR'. Searches both title and headline
			unless filter_data[:keywords].nil? || filter_data[:keywords].empty?
				query_keywords = [] # init subarray
				# Search title AND headline
				filter_data[:keywords].each do |k|
					# Case insensitive
					query_keywords.push("lower(services.title) #{like} '%#{k.downcase}%'")
					query_keywords.push("lower(services.headline) #{like} '%#{k.downcase}%'")
				end
				# Join sub-queries with 'OR' and prepend/append parenthesis to string
				query_keywords = query_keywords.join(' OR ').insert(0, '(').insert(-1, ')')
			end

			# Place all subqueries in an array
			query = [query_location, query_price, query_belt, query_keywords]
			 # Remove nil queries
			query.reject! {|q| q.nil? }
			# .joins(:lender) because we need to INNER JOIN users table to filter by belt field
			# Where combines all queries with 'AND'
			self.joins(:lender).where(query.join(' AND '))
		else
			# all users
			self.all
		end
	end

end

























