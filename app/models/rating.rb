class Rating < ActiveRecord::Base
	
	################################## ASSOCIATION ##################################

	belongs_to :author, class_name: 'User', foreign_key: "author_id"
	belongs_to :lender, class_name: 'User', foreign_key: "lender_id"

	################################## VALIDATION ##################################

	validates :stars, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
end
