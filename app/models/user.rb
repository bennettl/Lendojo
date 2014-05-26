class User < ActiveRecord::Base
	before_save { self.email = email.downcase }
	before_create :create_remember_token

	# Association
	# has_many :jobs_created, class_name: 'Job', dependent: :destroy
	# has_many :events, dependent: :destroy
	# has_many :news, dependent: :destroy

	# Validation
	validates :image, presence: true #profile image
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

	private

	# Create a new remember token (encrptyed string)
	def create_remember_token
		self.remember_token = User.encrypt(User.new_remember_token)
	end
end
