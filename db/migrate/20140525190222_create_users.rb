class CreateUsers < ActiveRecord::Migration

	# Always run these three commands
	# bundle exec rake db:rollback
	# bundle exec rake db:migrate
	# bundle exec rake test:prepare
	
	def change
		# All tables and columns for database

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
			t.string :belt, default: 'white' # color: white, green, blue, red, black
			t.text :summary
			# Location
			t.string :location # more specific, i.e. USC or 711 W. 27th Street
			t.string :city 
			t.string :state
			t.string :zip
			# Payment
			t.string :stripe_customer_id
			# Password
			t.string :password_digest
			# Session
			t.string :remember_token
			t.timestamps
			# Indexes
			t.index :email, unique: true
		end

		# Filters 
		 create_table :filters do |t|
		 	# Association
		 	t.belongs_to :user 
		 	t.string :title
		 	t.boolean :alert, default: false # Wheather user wants alerts to be shown for new services offered for filters
		 	# Serialized hash
		 	t.text :data
    		t.timestamps
	    end

		# User Services: table establishes relationship between users and services
		create_table :user_services do |t|
			t.integer :lender_id # owner of the service
			t.integer :lendee_id
			t.integer :service_id
			t.string :relationship_type # checks, pins, hidden
			t.string :status, default: 'pending' # pending, owner_called, scheduled_unconfirm, scheduled_confirmed, complete
			t.datetime :scheduled_date # date time when service is scheduled
			t.timestamps
			# Indexes
			t.index :lender_id
			t.index :lendee_id
			t.index :service_id
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
			t.timestamps
		end
		
		# Reviews
		create_table :reviews do |t|
			t.string :title
		    t.text :text
	    	t.timestamps
    	end
	
	end
end
