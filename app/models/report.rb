class Report < ActiveRecord::Base
	
	# Association
	belongs_to :author, class_name: 'User', foreign_key: 'author_id' # use lender_id instead of user_id

	# (Polymorphic) association, because the object being reported can be user/product/services
	belongs_to :reportable, polymorphic: true

	# Validation
	validates :reason, presence: true
	validates :summary, presence: true

end
