class CreateUsers < ActiveRecord::Migration

	# Always run these three commands
	# bundle exec rake db:rollback
	# bundle exec rake db:migrate
	# bundle exec rake test:prepare
	
	def change
		# All tables and columns for database

		# Users
		create_table :users do |t|
			# Basic Info
			t.attachment :avatar
			t.string :first_name
			t.string :last_name
			t.string :headline
			t.integer :age
			# Contact/Social
			t.string :email
			t.string :phone			
			# Location
			t.string :location # more specific, address
			t.string :city 
			t.string :state
			t.string :zip
			# determines if user is leader or not
			t.boolean :lender 
			# hidden info
			t.string :password_digest
			# session
			t.string :remember_token
			t.timestamps
		end

		# Services
		create_table :services do |t|
			t.belongs_to :user # member who created service
			t.attachment :main_img
			t.string :title
			t.string :headline # a sentence
			t.text :description # full description of service
			t.string :location #default to user location
			t.string :price #per hour/session (required)
			t.string :categories # broad
			t.string :tags # specific
			# rates/discounts
			# slide show
			# at A Glance” (skillshare)
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
