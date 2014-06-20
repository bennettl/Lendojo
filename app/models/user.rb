class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	before_create :create_remember_token

	# Association
	has_many :filters
	has_many :services, foreign_key: "lender_id", dependent: :destroy # use lender_id instead of user_id

	# RATINGS
	has_many :ratings_given, class_name: "Rating", foreign_key: "author_id", dependent: :destroy # Ratings that the user has given
	has_many :ratings_recieved, class_name: "Rating", foreign_key: "lender_id", dependent: :destroy # Ratings that the user has recieved

	# REVIEWS
	has_many :reviews_given, class_name: "Review", foreign_key: "author_id", dependent: :destroy # Reviews that user has given
	has_many :reviews_recieved, class_name: "Review", foreign_key: "lender_id", dependent: :destroy # Reviews that the user has recieved

    # Has many ... through explaination
    # Check: alias name (user.checks) 
    # Users_services: table name,
    # Source: the object we're connecting to, being returned
    # Dependent: destroy: if this object is remove, remove all associations
 	#  -> Where : filter association with a condition on the table

 	# The original user_services table!
    # has_many :user_services, dependent: :destroy

    # LENDEES

    # All the lendee's checks and pins
    has_many :lendee_user_services, class_name: "UserService", foreign_key: "lendee_id", dependent: :destroy
	
	# User_service table filter by relationship_type and lendee_id matches user_id
	has_many :lendee_check_user_services, -> { where relationship_type: 'check' }, 
				{ class_name: 'UserService' , foreign_key: "lendee_id", dependent: :destroy }
	has_many :lendee_pin_user_services,  -> { where relationship_type: 'pin' }, 
				{ class_name: 'UserService', foreign_key: "lendee_id", dependent: :destroy}

	# Association pulled from their respective table that includes data from Service Model
	has_many :lendee_checks, through: :lendee_check_user_services, source: :service, dependent: :destroy
	has_many :lendee_pins, through: :lendee_pin_user_services, source: :service, dependent: :destroy

	# LENDER
    # All the lender's checks and pins
    has_many :lender_user_services, class_name: "UserService", foreign_key: "lender_id", dependent: :destroy

	# User_service table filter by relationship_type and lender_id = user_id
	has_many :lender_check_user_services, -> { where relationship_type: 'check' }, 
				{ class_name: 'UserService',  foreign_key: "lender_id", dependent: :destroy }
	# has_many :lender_pin_user_services,  -> { where relationship_type: 'pin' }, 
	# 			{ class_name: 'UserService' }, foreign_key: "lender_id", dependent: :destroy

	# Association pulled from their respective table that includes data from Service Model
	has_many :lender_checks, through: :lender_check_user_services, source: :service, dependent: :destroy
	# has_many :lender_pins, through: :lender_pin_user_services, source: :service, dependent: :destroy


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
	validates :password, length: { minimum: 5 }, allow_nil: true
	
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	VALID_PHONE_REGEX = /\A[0-9]{3}-[0-9]{3}-[0-9]{4}\z/
	validates :phone, presence: true, format: { with: VALID_PHONE_REGEX }, uniqueness: { case_sensitive: false }

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


	# Searches users base similar (LIKE) to search hash
	def self.search(search)
		if !search.nil? && !search.empty?
			# Parameters
			query 	= []
			like 	= Rails.env.development? ? 'LIKE' : 'ILIKE' ; #case insensitive for postgres
			
			# Concatinate columns with || so search[:name] can search both columns
			query.push((search[:name].blank?) ? '' : "(first_name || ' ' || last_name) #{like} '%#{search[:name]}%'")
			
			query.reject! {|q| q.empty? }

			# Search for all fields
			self.where(query.join(' AND '))
		else
			self.all
		end
	end


	# Returns full name
	def name
		"#{first_name} #{last_name}"
	end

	# Has the current user given rating to other user?
	def given_rating_to?(other_user)
		self.ratings_given.find_by(lender_id: other_user.id)
	end


	################################################### BELT ###################################################
	

	################################################### USER - SERVICE ###################################################
	
	# Charge user's credit card for a specified amount
	def charge!(amount)
		customer_id = self.stripe_customer_id
		amount *= 100 # stripe measures amount by cents

		# Charge the user
		Stripe::Charge.create(
		    :amount => amount,
		    :currency => "usd",
		    :customer => customer_id
		)
	end

	# Create a new user_service relationship with service_id and relationship_type = 'check'
	def check!(service)
		self.lendee_user_services.create!(service_id: service.id, lender_id: service.lender.id, relationship_type: 'check')
	end

	# Remove an existing user_service relationship with service_id and relationship_type = 'check'
	def uncheck!(service)
		self.lendee_user_services.find_by(service_id: service.id, relationship_type: 'check').destroy
	end

	# Has the user already checked the service?
	def check?(service)
		self.lendee_user_services.find_by(service_id: service.id, relationship_type: 'check')
	end

	# Create a new user_service relationship with service_id and relationship type = 'pin'
	def pin!(service)
		self.lendee_user_services.create!(service_id: service.id, lender_id: service.lender.id, relationship_type: 'pin')
	end

	# Remove an existing user_service relationship with service_id and relationship type = 'pin'
	def unpin!(service)
		self.lendee_user_services.find_by(service_id: service.id, relationship_type: 'pin').destroy
	end

	# Has the user already pin the service? 
	def pin?(service)
		self.lendee_user_services.find_by(service_id: service.id, relationship_type: 'pin')
	end

	private

	# Create a new remember token (encrptyed string)
	def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)
	end
end
