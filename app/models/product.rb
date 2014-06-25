class Product < ActiveRecord::Base
	
	################################## ASSOCIATIONS ##################################
	has_many :reports_recieved, as: :reportable


	################################## GEOCODING ##################################

	# Which method returns object's geocodable address
	geocoded_by :full_address
	# Perform geocoding after valiation 
	after_validation :geocode, if: ->(obj){ obj.location_changed? || obj.city_changed? || obj.state_changed? || obj.zip_changed?  }
	
	def full_address
		"#{city}, #{state} #{zip}"
	end

	
	# Returns the title use for reports
	def report_title
		self.title
	end
end