class LenderApplication < ActiveRecord::Base
	
	################################## ASSOCIATION ##################################

	belongs_to :author, class_name: 'User', foreign_key: 'author_id' # use lender_id instead of user_id

	################################## ENUMS ##################################
	
	enum status: [ :pending, :approved, :denied ]

	################################## VALIDATION ##################################

	validates :keyword, presence: true
	validates :skill, presence: true
	validates :hours, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 168 } # 168 hours in a week
	validates :summary, presence: true

	################################## HELPER ##################################

end
