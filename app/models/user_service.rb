class UserService < ActiveRecord::Base
	include ActionView::Helpers::DateHelper


	################################## ASSOCIATION ##################################

	belongs_to :lendee, class_name: 'User'
	belongs_to :lender, class_name: 'User'
	belongs_to :service

	################################## ENUMS #################################

	enum relationship_type: [:checks, :pins, :hidden]
	enum status: [ :pending, :schedule_unconfirm, :schedule_confirmed, :complete ]

	################################## GEOCODING ##################################

	# Which method returns object's geocodable address
	geocoded_by :full_address
	# Perform geocoding after valiation 
	after_validation :geocode, if: ->(obj){ obj.address_changed? || obj.city_changed? || obj.state_changed? || obj.zip_changed?  }
	
	def full_address
		"#{address} #{city}, #{state} #{zip}"
	end

	################################## VALIDATION ##################################

	validates :lendee_id, presence: true
	validates :lender_id, presence: true
	validates :service_id, presence: true
	validates :address, presence: true
	validates :city, presence: true
	validates :state, presence: true,  length: {is: 2}
	validates :zip, presence: true, length: { minimum: 5 }
	validates :relationship_type, presence: true
	validates :status, presence: true
	 # length: {minimum: 5, maximum: 5}

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
		if self.date.nil?
			'N/A'
		else
			self.date.strftime("%B %e, %Y <br /><small>%A @ %l:%M %p</small>").html_safe
		end
	end

	# Displays either N/A or the location for the user service
	def scheduled_place_text
		"#{address} <br /> <small> #{city}, #{state} #{zip} </small>".html_safe
	end
end
