class UserService < ActiveRecord::Base
	# Association
	belongs_to :user
	belongs_to :service

	# Validations
	validates :user_id, presence: true
	validates :service_id, presence: true
end
