class Tag < ActiveRecord::Base
	before_save { |tag| tag.category = tag.category.downcase }

	################################## VALIDATION ##################################
	validates :category, 	presence: true
	validates :name, 	presence: true

	################################## INSTANCE METHODS ##################################

	# Show a titleize version of name
	def display_name
		self.name.titleize
	end

	################################## CLASS METHODS ##################################

	# Searches users base similar (LIKE) to search hash
	def self.search(search)
		puts search
		if !search.nil? && !search.empty?
			# Parameters
			query 	= []
			like 	= Rails.env.development? ? 'LIKE' : 'ILIKE' ; #case insensitive for postgres
			
			# Category: Push category to query
			unless search[:category].nil? || search[:category].empty?
				query.push("lower(category) = '#{search[:category].downcase.singularize}'")
			end  

			# Name: Push name query
			unless search[:name].nil? || search[:name].empty?
				query.push("lower(name) #{like} '%#{search[:name].downcase}%'",)
			end  

			# Remove nil queries
			query.reject! {|q| q.empty? }

			# Search for all fields
			self.where(query.join(' AND ')).limit(5)
		else
			# Empty scope, returns all but doesn't perform the actual query
			self.all.limit(5)
		end
	end

end
