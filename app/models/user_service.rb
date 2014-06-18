class UserService < ActiveRecord::Base
	include ActionView::Helpers::DateHelper

	# Association
	belongs_to :lendee, class_name: 'User'
	belongs_to :lender, class_name: 'User'
	belongs_to :service

	# Validations
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
end
