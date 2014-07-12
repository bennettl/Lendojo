class CreateUsers < ActiveRecord::Migration

	# Always run these three commands
	# bundle exec rake db:drop
	# bundle exec rake db:create
	# bundle exec rake db:migrate
	# bundle exec rake test:prepare
	# bundle exec rake db:populate

	# All tables and columns for database
	def change
		#################################### USERS ####################################
		create_table :users do |t|
			# Basic
			t.attachment 	:main_img
			t.string 		:first_name
			t.string 		:last_name
			t.string 		:headline, default: ''
			t.date 			:birthday
			# Contact/Social
			t.string 		:email, default: ''
			t.string 		:phone, default: ''			
			# Lender
			t.boolean 		:lender, default: false
			t.string 		:belt, default: 'N/A' # color: white, green, blue, red, black
			t.string 		:skill_level # skill level of lender
			t.integer 		:score, default: 0 # tatal score, use for leaderboards
			t.text 			:summary, default: ''
			# Location
			t.string 		:location, default: '' # alias name
			t.string 		:address, default: '' # Speific address, use for location tracking
			t.string 		:city, default: '' 
			t.string 		:state, default: ''
			t.string 		:zip, default: ''
			t.float 		:latitude
			t.float 		:longitude
			# Payment
			t.decimal 		:credits, precision: 8, scale: 2, default: 0
			t.string 		:stripe_customer_id
			# Referrals
			t.string		:referral_code, unique: true
			# Status
			t.integer 		:status, default: 0 # enum
			# Authentication/ Devise
			t.string 		:encrypted_password, null: false, default: ""
			## Recoverable
			t.string   		:reset_password_token
			t.datetime 		:reset_password_sent_at
			## Rememberable
			t.datetime 		:remember_created_at
			## Trackable
			t.integer  		:sign_in_count, default: 0, null: false
			t.datetime 		:current_sign_in_at
			t.datetime 		:last_sign_in_at
			t.string   		:current_sign_in_ip
			t.string   		:last_sign_in_ip
			## Confirmable
			# t.string   		:confirmation_token
			# t.datetime 		:confirmed_at
			# t.datetime 		:confirmation_sent_at
			# t.string   		:unconfirmed_email # Only if using reconfirmable
			## Lockable
			# t.integer  		:failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
			# t.string   		:unlock_token # Only if unlock strategy is :email or :both
			# t.datetime 		:locked_at
			## Omniauthable
			t.string 		:provider, default: ''
			t.string		:uid, default: ''
			# Password
			# t.string 		:password_digest
			# Timestamp
			t.timestamps
			# Indexes
			t.index 		:email                
			t.index 		:reset_password_token, unique: true
			# t.index 		:confirmation_token,   unique: true
			# t.index 		:unlock_token,         unique: true
		end

		#################################### SERVICES ####################################
		create_table :services do |t|
		 	# Association
			t.belongs_to 	:lender, class_name: 'User', foreign_key: 'lender_id' # use lender_id instead of user_id
			t.attachment 	:main_img
			t.string 		:title
			t.string 		:headline # a sentence
			t.text 			:summary # full description of service
			t.integer 		:price #per session (required)
			t.string 		:category # broad
			t.string 		:tags # specific
			t.boolean 		:hidden, default: false # hide service
			# Location: default to user location
			t.string 		:location # Alias name USC
			t.string 		:address # needs to be specific: 711 W. 27th Street
			t.string 		:city 
			t.string 		:state
			t.string 		:zip
			t.float 		:latitude
			t.float 		:longitude
			# rates/discounts
			# slide show
			# Timestamp
			t.timestamps
		end

		# Products
		create_table :products do |t|
			# Association
			t.belongs_to 	:lender, class_name: 'User', foreign_key: 'lender_id' # use lender_id instead of user_id
			t.attachment 	:main_img
			t.string 		:title
			t.string 		:headline # a sentence
			t.text 			:summary # full description of service
			t.integer 		:price #per session (required)
			t.string 		:category # broad
			t.string 		:tags # specific
			t.boolean 		:hidden, default: false # hide service
			# Location: default to user location
			t.string 		:location
			t.string 		:city 
			t.string 		:state
			t.string 		:zip
			t.float 		:latitude
			t.float 		:longitude
			# Timestamp
			t.timestamps
		end
		
		#################################### FILTERS ####################################
		create_table :filters do |t|
		 	# Association
		 	t.belongs_to :user 
		 	t.string :title
		 	t.boolean :alert, default: true # Wheather user wants alerts to be shown for new services offered for filters
		 	# Serialized hash
		 	t.text :data # location, price, belt, keyword
			# Timestamp
    		t.timestamps
	    end
		
		#################################### USER-SERVICES ####################################
		# User Services: table establishes relationship between users and services
		create_table :user_services do |t|
			t.integer 		:lender_id # owner of the service
			t.integer 		:lendee_id
			t.integer 		:service_id
			t.integer 		:relationship_type, default: 0 # enum
			t.integer 		:status, default: 0  # enum
			t.datetime 		:date # date time when service is scheduled
			# Location: default to service 
			t.string 		:address # needs to be specific
			t.string 		:city 
			t.string 		:state
			t.string 		:zip
			t.float 		:latitude
			t.float 		:longitude
			# Timestamp
			t.timestamps
			# Indexes
			t.index 		:lender_id
			t.index 		:lendee_id
			t.index 		:service_id
		end

		#################################### LENDER APPLICATION ####################################
		create_table :lender_applications do |t|
			# Association
			t.belongs_to 	:author, class_name: 'User', foreign_key: 'author_id'
			t.text 			:keyword # []
			t.string 		:skill # skill level of lender
			t.integer 		:hours # of hours lender can commit per week
			t.text 			:summary
			t.integer 		:status, default: 0 # enum
			t.text 			:staff_notes, default: ''
			t.timestamps
		end
	
		#################################### RATINGS ####################################
    	create_table :ratings do |t|
			t.belongs_to 	:author, class_name: 'User', foreign_key: 'author_id' # author of rating 
			t.belongs_to 	:lender, class_name: 'User', foreign_key: 'lender_id' # target of rating
			t.integer 		:stars, default: 0
			t.timestamps
	    end
		
		#################################### REVIEWS ####################################
		create_table :reviews do |t|
			# Association
			t.belongs_to 	:author, class_name: 'User', foreign_key: 'author_id' # author of review
			t.belongs_to 	:lender, class_name: 'User', foreign_key: 'lender_id' # target of the review
			t.string 		:title # will act as headline
		    t.text 			:summary
			t.integer 		:stars, default: 0
			t.string 		:category # music, art, education
			t.integer 		:status, default: 0 # enum
	    	t.timestamps
    	end

		#################################### REFFERALS ####################################
		create_table :referrals do |t|
			# Association 
			t.belongs_to 	:referrer, class_name: 'User', foreign_key: 'referrer_id' # creator of the referral
			t.belongs_to 	:referree, class_name: 'User', foreign_key: 'referree_id' # person being referred
			t.integer 		:status, default: 0 # enum
		    t.timestamps
	    end

		#################################### DISCOUNTS ####################################
		 create_table :discounts do |t|
			t.belongs_to 	:lender, class_name: 'User', foreign_key: 'lender_id' # target of the review
			t.belongs_to 	:service
			t.integer 		:type, default: 0 # percentage, amount
			t.datetime 		:expire_date
			t.timestamps
	    end

		#################################### TAGS ####################################
		create_table :tags do |t|
			t.string 		:category
			t.string 		:name
			t.integer 		:count, default: 0
		end

		#################################### REPORTS ####################################
    	create_table :reports do |t|
			# Association
			t.belongs_to 	:author, class_name: 'User', foreign_key: 'author_id' # author of review
			t.integer 		:reportable_id  # id of user, product, or service
			t.string 		:reportable_type # 'user', 'product', 'service'
			t.integer 		:reason, default: 0 # enum
			t.integer 		:action, default: 0 # enum
			t.text 			:summary
			t.text 			:staff_notes # notes by staff
			t.integer 		:status, default: 0
			t.timestamps
	    end
	end
end
