class Review < ActiveRecord::Base
	
	################################## ASSOCIATION ##################################

	belongs_to :author, class_name: 'User'
	belongs_to :lender, class_name: 'User'

	# Polymorpic associations 
	has_many :reports_received, class_name: "Report", as: :reportable


	################################## ENUMS ##################################
	enum status: [ :pending, :approved ]

	################################## VALIDATION ##################################

	validates :title, presence: true
	validates :stars, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
	validates :summary, presence: true

	################################## REPUTATION SYSTEM ##################################

	has_reputation :up_votes, source: :user  # of users that found this review helpful
	has_reputation :total_votes, source: :user  # total votes casted

end
