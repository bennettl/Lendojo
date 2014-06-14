class Service < ActiveRecord::Base

	# Association
	belongs_to :user

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
