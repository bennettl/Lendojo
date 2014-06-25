class UserService < ActiveRecord::Base
	include ActionView::Helpers::DateHelper

	################################## ASSOCIATION ##################################
	belongs_to :lendee, class_name: 'User'
	belongs_to :lender, class_name: 'User'
	belongs_to :service

	################################## GEOCODING ##################################

	# Which method returns object's geocodable address
	geocoded_by :full_address
	# Perform geocoding after valiation 
	after_validation :geocode, if: ->(obj){ obj.location_changed? || obj.city_changed? || obj.state_changed? || obj.zip_changed?  }
	
	def full_address
		"#{city}, #{state} #{zip}"
	end

	################################## VALIDATION ##################################

	validates :lendee_id, presence: true
	validates :lender_id, presence: true
	validates :service_id, presence: true
	validates :relationship_type, presence: true
	validates :status, presence: true

	def request_time
		time_ago_in_words(self.updated_at) + " ago"
	end

	# Charge the lendee for service amount
	def charge!
		price = self.service.price
		self.lendee.charge!(price)
	end

	# Display either N/A or a formatted date for scheudle date
	def scheduled_date_text
		if self.scheduled_date.nil?
			'N/A'
		else
			self.scheduled_date.strftime("%B %e, %Y <br /><small>%A @ %l:%M %p</small>").html_safe
		end
	end

	# Displays either N/A or the location for the user service
	def scheduled_place_text
		if self.city.nil?
			'N/A'
		else
			full_address.html_safe
		end
	end
end
