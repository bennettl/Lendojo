class User < ActiveRecord::Base

	# For us states parsing
	include ApplicationHelper
	
	before_save :before_save_callback
	after_create :after_create_callback

	################################## ASSOCIATIONS ##################################

	has_many :filters
	has_many :services, foreign_key: "lender_id", dependent: :destroy # use lender_id instead of user_id

	### RATINGS
	has_many :ratings_given, class_name: "Rating", foreign_key: "author_id", dependent: :destroy # Ratings that the user has given
	has_many :ratings_recieved, class_name: "Rating", foreign_key: "lender_id", dependent: :destroy # Ratings that the user has recieved

	### REVIEWS
	has_many :reviews_given, class_name: "Review", foreign_key: "author_id", dependent: :destroy # Reviews that user has given
	has_many :reviews_recieved, class_name: "Review", foreign_key: "lender_id", dependent: :destroy # Reviews that the user has recieved

	## REFERRALS
	has_many :referrals, class_name: "Referral", foreign_key: "referrer_id", dependent: :destroy
	has_one  :referrer, class_name: "Referral", foreign_key: "referree_id", dependent: :destroy

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
	has_many :reports_given, 	class_name: "Report", foreign_key: "author_id", dependent: :destroy

	################################## ENUMS #################################

	enum status: [ :inactive, :active, :admin, :warned, :suspended, :banned ]

	################################## ATTACHMENTS ##################################

	has_attached_file :main_img, 
						:styles => { :medium => "200x200>", :thumb => "100x100>" }, 
						:default_url => "/images/users/main_img/:style/missing.png", 
						:url => "/assets/users/main_img/:id/:style/:basename.:extension",
						:path => ":rails_root/public/assets/users/main_img/:id/:style/:basename.:extension"
	validates_attachment_content_type :main_img, :content_type => /\Aimage\/.*\Z/

	################################## AUTHENTICATION/SESSION/REGISTRATION ##################################

	# Include default devise modules. Others available are: :confirmable, :lockable, :timeoutable
	devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :registerable, :omniauthable, :omniauth_providers => [:facebook, :twitter, :google]

	################################## GEOCODING ##################################

	# Which method returns object's geocodable address
	geocoded_by :full_address
	# Perform geocoding after valiation 
	after_validation :geocode, if: ->(obj){ obj.location_changed? || obj.city_changed? || obj.state_changed? || obj.zip_changed?  }
	
	def full_address
		"#{address} #{city}, #{state} #{zip}"
	end

	################################## OMNIAUTH ##################################

	# Finds an existing user by provider and uid. If no user is found, a new one is initialize with information provided by omniauth
	# Providers: 'facebook', 'twitter', 'google'
	def self.from_omniauth(auth)
		self.where(auth.slice(:provider, :uid)).first_or_initialize do |user|
			# Populate fields differently depending on provider
			case user.provider
				when 'facebook'
					# Basic Info
					user.first_name		= auth.info.first_name
					user.last_name		= auth.info.last_name
					user.birthday 		= Date.strptime(auth.extra.raw_info.birthday, "%m/%d/%Y")
					# Location (need to parse: i.e. Venice, California)
					location_arr		= auth.info.location.split(', ')
					user.city			= location_arr[0]
					user.state			= user.us_state_initials_from_name(location_arr[1])
					# Contact
					user.email 			= auth.info.email
					user.phone 			= auth.info.phone
				when 'twitter'
					# Basic Info
					name_arr 			= auth.info.name.split(" ")
					user.first_name		= name_arr.first
					user.last_name 		= name_arr.last
					user.headline 		= auth.extra.raw_info.description[0..38]
					# Location
					user.location 		= auth.info.location
				when 'google'
					# Basic Info
					user.first_name		= auth.info.first_name
					user.last_name		= auth.info.last_name
					user.birthday 		= Date.strptime(auth.extra.raw_info.birthday, "%m/%d/%Y") unless auth.extra.raw_info.birthday.nil?
					# Contact
					user.email 			= auth.info.email
			end

			user.main_img 				= URI.parse(auth.info.image)
			# Authentication/ Devise
			user.password 				= Devise.friendly_token[0,20]
			user.password_confirmation 	= user.password
		end
	end

 	# If we need to copy data from session whenever a user is initialized before sign up, we just need to implement new_with_session in our model. Here is an example that copies the facebook email if available:
	def self.new_with_session(params, session)
		super.tap do |user|
			if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
				user.email = data["email"] if user.email.blank?
			end
		end
	end

	# Ensure email is required only if provider is absent (twitter!)
	def email_required?
		super && provider.blank?
	end
	def password_required?
		super && provider.blank?
	end

	################################## ATTACHMENT ##################################

	################################## VALIDATION ##################################

	# validates :main_img, presence: true #profile image
	validates :first_name, 	presence: true
	validates :last_name, 	presence: true
	validates :headline,	allow_nil: true, allow_blank: true, length: { maximum: 90 }
	validates :state, 		allow_nil: true, allow_blank: true, length: { is: 2 }
	validates :zip, 		allow_nil: true, allow_blank: true, length: { minimum: 5 }
	validates :password, 	allow_nil: true, length: { minimum: 5 }
	
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :email, 		allow_nil: true, allow_blank: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false } # allow nil for twitter!
	VALID_PHONE_REGEX = /\A[0-9]{3}-[0-9]{3}-[0-9]{4}\z/
	validates :phone, 		allow_nil: true, allow_blank: true, format: { with: VALID_PHONE_REGEX }, uniqueness: { case_sensitive: false }


	################################## RAKNING ##################################

	# Ranking Algorithm 
	# Number of Ratings = R
	# Quality of ratings= Q = average of all ratings on 5.

	# {
	# Average Number of hours per week = n
	# Commitment of hours per week=m
	# Number of weeks person has been with us and lended a service on a given week=w
	# Number of weeks a person has been with us totally=W
	# }
	# “Consistency score” = C= [(0.3)*(n/m)+0.7*(w/W)]
	
	# NOTE: The consistency score gives us the consistency of a person more than just the total number of sessions and also takes into account how long the person has been a lender. This is better than just the Total number of sessions because in the case of a service where the lender can’t provide the service too many times in a week we can still measure his consistency and quality of the service while still rewarding the number of times the service is offered.

	# Weight for each dimension:
	# C=0.4
	# R=0.25
	# Q=0.35

	# Lending Score (L):
	# 0.4*C + 0.25*(R/x) + 0.35(Q/5)
	# where x is the minimum number of ratings for each belt.

	# Black belt 	(x=30):  L>0.85
	# Red 			(x=25): L= 0.75-0.85 (inclusive)
	# Blue (x=20): L= 0.4-0.74
	# Green (x=10): L=0.2-0.39
	# White (x=5): L=0-0.2

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
		update_belt
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
			
			# Remove nil queries
			query.reject! {|q| q.empty? }

			# Search for all fields
			self.where(query.join(' AND '))
		else
			# Empty scope, returns all but doesn't perform the actual query
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

	def belongs_to?(user)
		self === user
	end

	# Make sure email is lower case, first/last name is trimmed
	def before_save_callback
		self.email 			= email.downcase
		self.first_name.strip!
		self.last_name.strip!
	end
	
	# Create referral code
	def after_create_callback
		# Create a referral if referral_code is not empty, and exiting user with referrral code is found
		unless referral_code.nil? || referral_code.empty?
			user = User.find_by(referral_code: referral_code)
			if user
				user.refer!(self) # create the referral
			end
		end
		# Create a referral code for the new user
		count 			= User.where("first_name = '#{self.first_name}'").count.to_s
		referral_code 	= self.first_name.downcase + count
		update_attribute('referral_code', referral_code)
	end

	################################## BELT ##################################
	
	
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
		return self.lendee_user_services.create!(service_id: service.id, 
												lender_id: service.lender.id, 
												address: service.address,
												city: service.city,
												state: service.state,
												zip: service.zip,
												relationship_type: 'check')
	end

	################################## USER - SERVICE ##################################

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
		self.lendee_user_services.create!(service_id: service.id, 
											lender_id: service.lender.id, 
											address: service.address,
											city: service.city,
											state: service.state,
											zip: service.zip,
											relationship_type: 'pin')
	end

	# Remove an existing user_service relationship with service_id and relationship type = 'pin'
	def unpin!(service)
		self.lendee_user_services.find_by(service_id: service.id, relationship_type: 'pin').destroy
	end

	# Has the user already pin the service? 
	def pin?(service)
		self.lendee_user_services.find_by(service_id: service.id, relationship_type: 'pin')
	end
	
	################################## RATE/REVIEW ##################################

	# Rate a lender. Accepts 2 arguments, lender and rating_params (information about the rating)
	def rate!(lender, rating_params)
		# Combine the two hash and create the rating
		lender_hash = { lender_id: lender.id } 
		merged_hash = lender_hash.merge(rating_params)
		self.ratings_given.create!(merged_hash)
	end

	# Review a lender. Accepts 2 arguments, lender and rating_params (information about the rating)
	def review!(lender, review_params)
		# Combine the two hash and create the review
		lender_hash = { lender_id: lender.id }
		merged_hash = lender_hash.merge(review_params)
		self.reviews_given.create!(merged_hash)
	end

	################################## REFERRAL ##################################

	# Refer another user.
	def refer!(other_user)
		self.referrals.create!(referree_id: other_user.id)
	end


	################################## REPORT ##################################
	
	# Reports a reportable object. Accepts 2 arguments, reportable and report_params (information about the report)
	def report!(reportable, report_params)
		# Combine the two hash and create the report
		report_hash 		= { reportable_id: reportable.id, reportable_type: reportable.class.name }
		merged_hash	 		= report_hash.merge(report_params) 
		self.reports_given.create!(merged_hash)
	end

	################################## PRIVATE ##################################

	private

	# Create a new remember token (encrptyed string)
	def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)
	end
end
