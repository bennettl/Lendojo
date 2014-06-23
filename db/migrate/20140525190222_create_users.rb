class CreateUsers < ActiveRecord::Migration

	# Always run these three commands
	# bundle exec rake db:drop
	# bundle exec rake db:create
	# bundle exec rake db:migrate
	# bundle exec rake test:prepare
	# bundle exec rake db:populate

	# All tables and columns for database
	def change
		# Users
		create_table :users do |t|
			# Basic
			t.attachment :main_img
			t.string :first_name
			t.string :last_name
			t.string :headline
			t.integer :age
			# Contact/Social
			t.string :email
			t.string :phone			
			# Lender
			t.boolean :lender
			t.string :belt, default: 'N/A' # color: white, green, blue, red, black
			t.string :skill_level # skill level of lender
			t.integer :score # tatal score, use for leaderboards
			t.text :summary
			# Location
			t.string :location # more specific, i.e. USC or 711 W. 27th Street
			t.string :city 
			t.string :state
			t.string :zip
			# Payment
			t.decimal :credits, precision: 8, scale: 2, default: 0
			t.string :stripe_customer_id
			# Status
			t.string :status, default: :inactive # inactive, active, admin, warned, suspended, banned
			# Password
			t.string :password_digest
			# Session
			t.string :remember_token
			t.timestamps
			# Indexes
			t.index :email, unique: true
		end

		# Services
		create_table :services do |t|
		 	# Association
			t.belongs_to :lender, class_name: 'User', foreign_key: 'lender_id' # use lender_id instead of user_id
			t.attachment :main_img
			t.string :title
			t.string :headline # a sentence
			t.text :summary # full description of service
			t.string :location #default to user location
			t.integer :price #per session (required)
			t.string :category # broad
			t.string :tags # specific
			t.boolean :hidden, default: false # hide service
			# rates/discounts
			# slide show
			t.timestamps
		end

		# Products
		create_table :products do |t|
			# Association
			t.belongs_to :lender, class_name: 'User', foreign_key: 'lender_id' # use lender_id instead of user_id
			t.attachment :main_img
			t.string :title
			t.string :headline # a sentence
			t.text :summary # full description of service
			t.string :location #default to user location
			t.integer :price #per session (required)
			t.string :category # broad
			t.string :tags # specific
			t.boolean :hidden, default: false # hide service
			t.timestamps
		end
		
		# Filters 
		create_table :filters do |t|
		 	# Association
		 	t.belongs_to :user 
		 	t.string :title
		 	t.boolean :alert, default: true # Wheather user wants alerts to be shown for new services offered for filters
		 	# Serialized hash
		 	t.text :data # location, price, belt, keywords
    		t.timestamps
	    end
		
		# User Services: table establishes relationship between users and services
		create_table :user_services do |t|
			t.integer :lender_id # owner of the service
			t.integer :lendee_id
			t.integer :service_id
			t.string :relationship_type # checks, pins, hidden
			t.string :status, default: 'pending' # pending, scheduled_unconfirm, scheduled_confirmed, complete
			t.datetime :scheduled_date # date time when service is scheduled
			t.timestamps
			# Indexes
			t.index :lender_id
			t.index :lendee_id
			t.index :service_id
		end

		# Lender Application
		create_table :lender_applications do |t|
			t.belongs_to :author, class_name: 'User', foreign_key: 'author_id'
			t.text :categories # []
			t.string :skill # skill level of lender
			t.integer :hours # of hours lender can commit per week
			t.text :summary
			t.string :status, default: 'pending' # pending, approve, denied
			t.text :staff_notes
			t.timestamps
		end
	
    	# Ratings
    	create_table :ratings do |t|
			t.belongs_to :author, class_name: 'User', foreign_key: 'author_id' # author of rating 
			t.belongs_to :lender, class_name: 'User', foreign_key: 'lender_id' # target of rating
			t.integer :stars, default: 0
			t.timestamps
	    end
		
		# Reviews
		create_table :reviews do |t|
			# Association
			t.belongs_to :author, class_name: 'User', foreign_key: 'author_id' # author of review
			t.belongs_to :lender, class_name: 'User', foreign_key: 'lender_id' # target of the review
			t.string :title # will act as headline
		    t.text :summary
			t.integer :stars, default: 0
			t.string :category # music, art, education
			t.string :status, default: 'pending' # pending, approved
	    	t.timestamps
    	end

    	# Reports
    	create_table :reports do |t|
			t.belongs_to :author, class_name: 'User', foreign_key: 'author_id' # author of review
			t.integer :reportable_id  # id of user, product, or service
			t.string :reportable_type # 'user', 'product', 'service'
			t.string :reason # spam or misleading content, fraud, 
			t.string :action # n/a, warn, suspend , ban
			t.text :summary
			t.text :staff_notes # notes by staff
			t.string :status, default: 'pending' # pending, active, resolved
			t.timestamps
	    end
	end
end
