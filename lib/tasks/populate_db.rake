namespace :db do
	desc 'Fill database with sample data' 
	task populate: :environment do
		populate_admin
		populate_users
		populate_services
	end	

	def populate_admin
		# Create Bennett
		User.create!(first_name: 'Bennett',
						last_name: 'Lee',
						headline: Faker::Lorem.sentences(1).join("\n\n"),
						age: 'age',
						email: 'bennettl908@yahoo.com',
						phone: '800-123-4567',
						location: 'USC',
						city: 'Los Angeles',
						state: 'CA',
						zip: '90007',
						lender: true,
						password: 'paper',
						password_confirmation: 'paper')

	end

	
	def populate_users
		# Create 40 users
		40.times do |n|
			first_name 		= Faker::Name.first_name
			last_name 		= Faker::Name.last_name
			headline 		= Faker::Lorem.sentences(3).join(' ')
			age 			= 21
			email			=  Faker::Internet.email
			phone			= '(415)-812-8901'
			location		=  Faker::Address.street_address
			state 			= 'CA'
			city			=  Faker::Address.city
			zip 			= '90007'
			lender 			= false
			
			# Create the user
			User.create!(first_name: first_name,
							last_name: last_name,
							headline: headline,
							age: age,
							email: email,
							phone: phone,
							location: location,
							city: city,
							state: state,
							zip: zip,
							lender: lender, 
							password: 'qwerty2',
							password_confirmation: 'qwerty2')
							
		end
	end

	def populate_services
		user 	= User.find_by email: "bennettl908@yahoo.com"

		# User will create 20 services 
		20.times do |n|
			title 			= "Service Title #{n}"
			headline 		= Faker::Lorem.sentences(3).join(' ')
			description 	= Faker::Lorem.paragraphs(5).join("\n\n")
			location 		= user.location
			price 			= "10/hr"
			categories 		= "Computer"
			tags 			= "courses"
			user.services.create!(title: title, 
									headline: headline, 
									description: description, 
									location: location, 
									price: price,
									categories: categories, 
									tags: tags )
		end
	end

	def random_date
		[*1..30].sample.days.from_now.to_date
	end
	
end