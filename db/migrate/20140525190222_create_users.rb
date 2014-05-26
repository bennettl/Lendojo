class CreateUsers < ActiveRecord::Migration

	# Always run these three commands
	# bundle exec rake db:rollback
	# bundle exec rake db:migrate
	# bundle exec rake test:prepare
	
	def change
		# All tables and columns for database

		# Users
		create_table :users do |t|
			# hidden info
			t.string :password_digest
			# session
			t.string :remember_token
			# basic info
			t.string :image #profile image
			t.string :first_name
			t.string :last_name
			t.string :headline
			t.integer :age
			t.string :location # more specific
			t.string :city 
			t.string :email
			t.string :phone
			t.timestamps
		end

		# Services
		create_table :services do |t|
			t.string :image 
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
		
		create_table :reviews do |t|

	      	t.timestamps
    	end
	
	end
end
