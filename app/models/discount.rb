class Discount < ActiveRecord::Base
	################################## ASSOCIATION ##################################

	belongs_to :referrer, class_name: 'User'
	belongs_to :referree, class_name: 'User'

	################################## ENUMS ##################################
	enum status: [ :inactive, :active ]
end
