class Review < ActiveRecord::Base
	# Association
	belongs_to :author, class_name: 'User'
	belongs_to :lender, class_name: 'User'

	# Validation
	validates :title, presence: true
	validates :stars, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 5 }
	validates :summary, presence: true

	# Reputation system
	has_reputation :up_votes, source: :user  # of users that found this review helpful
	has_reputation :total_votes, source: :user  # total votes casted

end
