class Referral < ActiveRecord::Base
	@@credit = 10.0

	def self.credit
		@@credit
	end

	before_update :give_credit, :if => :status_changed?

	################################## ASSOCIATION ##################################

	belongs_to :referrer, class_name: 'User'
	belongs_to :referree, class_name: 'User'

	################################## ENUMS ##################################
	enum status: [ :inactive, :active ]

	private 

	# Provide credit to referrer
	def give_credit
		if active?
			self.referrer.update_attribute('credits', self.referrer.credits + Referral.credit)
		end
	end
end
