class Service < ActiveRecord::Base

	# Association
	belongs_to :user

    has_many :user_services, foreign_key: "service_id" ,dependent: :destroy

	# Items are services/products user added  to checklist
	# has_many :past_customers, through: :checklist_items, source: :user, dependent: :destroy
	# Pins are services 
	# has_many :interested_customers, through: :user_services, source: :user

	# Attachment 
	has_attached_file :main_img,
						:styles => { :medium => "500x500>", :thumb => "150x150>" }, 
						:default_url => "/images/services/main_img/:style/missing.png", 
						:url => "/assets/services/:id/:style/:basename.:extension",
						:path => ":rails_root/public/assets/services/:id/:style/:basename.:extension"
	validates_attachment_content_type :main_img, :content_type => /\Aimage\/.*\Z/

	# Validation
	validates :title, presence: true
	validates :headline, presence: true
	validates :description, presence: true
	validates :location, presence: true
	validates :price, presence: true
	validates :categories, presence: true

end
