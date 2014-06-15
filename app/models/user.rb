class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	before_create :create_remember_token

	# Association
	has_many :services, dependent: :destroy

    # Has many ... through explaination
    # Check: alias name (user.checks) 
    # Users_services: table name,
    # Source: the object we're connecting to, being returned
    # Dependent: destroy: if this object is remove, remove all associations
 	#  -> Where : filter association with a condition on the table
    	
	# User_service table filter by relationship_type
    has_many :user_services, dependent: :destroy
	has_many :check_user_services, -> { where relationship_type: 'check' }, { class_name: :UserService }	
	has_many :pin_user_services,  -> { where relationship_type: 'pin' }, { class_name: :UserService }

	# Association pulled from their respective table that includes data from Service Model
	has_many :checks, through: :check_user_services, source: :service, dependent: :destroy
	has_many :pins, through: :pin_user_services, source: :service, dependent: :destroy

	# Pins are services users bookmarked
	# has_many :pins, { through: :user_servicees, source: :service, dependent: :destroy }, -> { where("relationship_type = ?", 'check') }

	# Attachments: main_img
	has_attached_file :main_img, 
						:styles => { :medium => "200x200>", :thumb => "100x100>" }, 
						:default_url => "/images/users/main_img/:style/missing.png", 
						:url => "/assets/users/main_img/:id/:style/:basename.:extension",
						:path => ":rails_root/public/assets/users/main_img/:id/:style/:basename.:extension"
	validates_attachment_content_type :main_img, :content_type => /\Aimage\/.*\Z/

	# Validation
	# validates :main_img, presence: true #profile image
	validates :first_name, presence: true
	validates :last_name, presence: true
	validates :headline, presence: true
	validates :age, presence: true
	validates :location, presence: true # more specific
	validates :city, presence: true 
	validates :email, presence: true, uniqueness: true
	validates :phone, presence: true
	
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	# validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	validates :password, length: { minimum: 5 }

	# Handles password 
	has_secure_password

	# Create a random string 
	def self.new_remember_token
	    SecureRandom.urlsafe_base64
	end

	# Encrpty a string with SHA1
	def self.encrypt(token)
	    Digest::SHA1.hexdigest(token.to_s)
	end

	# Returns full name
	def name
		"#{first_name} #{last_name}"
	end

	################################################### USER - SERVICE ###################################################
	
	# Create a new user_service relationship with service_id and relationship_type = 'check'
	def check!(service)
		self.user_services.create!(service_id: service.id, relationship_type: 'check')
	end

	# Remove an existing user_service relationship with service_id and relationship_type = 'check'
	def uncheck!(service)
		self.user_services.find_by(service_id: service.id, relationship_type: 'check').destroy
	end

	# Has the user already checked the service?
	def check?(service)
		self.user_services.find_by(service_id: service.id, relationship_type: 'check')
	end

	# Create a new user_service relationship with service_id and relationship type = 'pin'
	def pin!(service)
		self.user_services.create!(service_id: service.id, relationship_type: 'pin')
	end

	# Remove an existing user_service relationship with service_id and relationship type = 'pin'
	def unpin!(service)
		self.user_services.find_by(service_id: service.id, relationship_type: 'pin').destroy
	end

	# Has the user already pin the service? 
	def pin?(service)
		self.user_services.find_by(service_id: service.id, relationship_type: 'pin')
	end

	private

	# Create a new remember token (encrptyed string)
	def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)
	end
end
