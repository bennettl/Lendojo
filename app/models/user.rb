class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	before_create :create_remember_token

	################################## ASSOCIATIONS ##################################

	has_many :filters
	has_many :services, foreign_key: "lender_id", dependent: :destroy # use lender_id instead of user_id

	### RATINGS
	has_many :ratings_given, class_name: "Rating", foreign_key: "author_id", dependent: :destroy # Ratings that the user has given
	has_many :ratings_recieved, class_name: "Rating", foreign_key: "lender_id", dependent: :destroy # Ratings that the user has recieved

	### REVIEWS
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

    ### LENDEES

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

	### LENDER

	has_one :lender_app, class_name: 'LenderApplication', foreign_key: 'author_id', dependent: :destroy

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


	# Polymorpic associations 
	has_many :reports_received, class_name: "Report", as: :reportable
	has_many :reports_given, class_name: "Report", foreign_key: "author_id", dependent: :destroy

	# Attachments: main_img
	has_attached_file :main_img, 
						:styles => { :medium => "200x200>", :thumb => "100x100>" }, 
						:default_url => "/images/users/main_img/:style/missing.png", 
						:url => "/assets/users/main_img/:id/:style/:basename.:extension",
						:path => ":rails_root/public/assets/users/main_img/:id/:style/:basename.:extension"
	validates_attachment_content_type :main_img, :content_type => /\Aimage\/.*\Z/

	################################## VALIDATION ##################################

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

	################################## SESSION ##################################

	# Create a random string 
	def self.new_remember_token
	    SecureRandom.urlsafe_base64
	end

	# Encrpty a string with SHA1
	def self.encrypt(token)
	    Digest::SHA1.hexdigest(token.to_s)
	end

	################################## RAKNING ##################################


	# Ranking Algorithm 
	# Ranking is base on 3 dimensions
		# 1. Number of sessions (amount of commitment)
		# 2. Number of ratings (gives ratings more validity)
		# 3. Quality of ratings (feedback on work)
	# Upper-bound. Lenders who past this threshold will recieve a black belt. Each one counts as 100% 
		# 1. 3 sessions/week * 4 weeks/month * 10 months = 120 sessions
		# 2. 40 ratings
		# 3. 4.5 stars
	# Weight. How important is each dimension
		# 1. 0.70
		# 2. 0.15
		# 3. 0.15
	# Belt Distribution
		# Black : 90% 
		# Red 	: 70%
		# Blue 	: 40%
		# Green : 10%
		# White : 0%
	# Example cases
		# Black : 120 services | 20 ratings | 4.5 avg rating 	= 0.7 + 0.07 + 0.15 	= 0.92
		# Red 	: 100 services | 20 ratings | 4.5 avg rating 	= 0.58 + 0.07 + .15 	= 0.80
 		# Blue 	: 60 services  | 29 ratings | 4.5 avg rating  	= 0.35 + 0.11 + 0.15 	= 0.61
		# Green : 30 services  | 10 ratings | 4.5 avg rating 	= 0.175 + 0.0375 + 0.15 = 0.36
		# White : 10 services  |  3 ratings | 4.5 avg rating 	= 0.06 + 0.01 + 0.15 	= 0.22

	# Upper bound
	@@UPPER_BOUND_SESSION		= 120
	@@UPPER_BOUND_RATINGS		= 40
	@@UPPER_BOUND_AVG_RATING 	= 4.5
	# Weight
	@@WEIGHT_SESSION			= 0.15
	@@WEIGHT_RATINGS 			= 0.15
	@@WEIGHT_AVG_RATINGS		= 0.15

	# Update the score of the user and the belt
	def update_score
		# sessions_score = /@@UPPER_BOUND_SESSION
		# ratings_score = /@@UPPER_BOUND_RATINGS
		# avg_ratings_score = /@@UPPER_BOUND_AVG_RATING
		score = sessions_score + ratings_score + avg_ratings_score
		
		self.update_attribute('score', score)
		update_belt()
	end

	# Update the belt base on the score
	def update_belt		
		if self.score < 10
			belt = 'white'
		elsif self.score < 20
			belt = 'green'		
		elsif self.score < 30
			belt = 'blue'
		elsif self.score < 40
			belt = 'red'
		else 
			belt = 'black'
		end

		# Update the belt
		self.update_attribute('belt', belt)
	end

	################################## CLASS METHODS ##################################

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

	################################## INSTANCE METHODS ##################################

	# Returns full name
	def name
		"#{first_name} #{last_name}"
	end

	# Returns the title use for reports
	def report_title
		self.name
	end

	# Has the current user given rating to other user?
	def given_rating_to?(other_user)
		self.ratings_given.find_by(lender_id: other_user.id)
	end


	################################## BELT ##################################
	
	################################## USER - SERVICE ##################################
	
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

	################################## PRIVATE ##################################

	private

	# Create a new remember token (encrptyed string)
	def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)
	end
end
