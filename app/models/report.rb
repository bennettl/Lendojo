class Report < ActiveRecord::Base
	
	################################## ASSOCIATION ##################################

	belongs_to :author, class_name: 'User', foreign_key: 'author_id' # use lender_id instead of user_id

	# (Polymorphic) association, because the object being reported can be user/product/services
	belongs_to :reportable, polymorphic: true

	################################## VALIDATION ##################################

	validates :reason, presence: true
	validates :summary, presence: true

end
