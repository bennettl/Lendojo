namespace :db do
	desc 'Fill database with sample data' 
	task populate: :environment do
		populate_admin
		populate_users
		populate_services
		#populate_user_services
	end	

	def populate_admin
		# Create Bennett
		User.create!(first_name: 'Bennett',
						last_name: 'Lee',
						headline: "Aspiring Entreprenuer, Veteran Software Developer, Dabbling Musician",
						summary: Faker::Lorem.paragraphs(2).join("\n\n"),
						age: '21',
						email: 'bennettl908@yahoo.com',
						phone: '800-123-4567',
						location: 'USC',
						city: 'Los Angeles',
						state: 'CA',
						zip: '90007',
						lender: true,
						belt: 'black',
						password: 'paper',
						password_confirmation: 'paper')

	end
	
	def populate_users
		# Create 40 users
		40.times do |n|
			first_name 		= Faker::Name.first_name
			last_name 		= Faker::Name.last_name
			headline 		= Faker::Lorem.sentences(3).join(' ')
			summary 	    = Faker::Lorem.paragraphs(2).join("\n\n")
			age 			= 21
			email			=  Faker::Internet.email
			phone			= Faker::Base.numerify('###-###-####')
			location		=  Faker::Address.street_address
			state 			= 'CA'
			city			=  Faker::Address.city
			zip 			= '90007'
			lender 			= false
			belt 			= random_belt

			# Create the user
			User.create!(first_name: first_name,
							last_name: last_name,
							headline: headline,
							summary: summary,
							age: age,
							email: email,
							phone: phone,
							location: location,
							city: city,
							state: state,
							zip: zip,
							lender: lender, 
							belt: belt,
							password: 'qwerty2',
							password_confirmation: 'qwerty2')
							
		end
	end

	def populate_services
		users = User.limit(5)
		# Each user will create 8 services
		users.each do |u|
			8.times do |n|
				hash 			= random_hash
				title 			= random_hash[:desc][:title] + " #{n}"
				headline 		= hash[:desc][:headline]
				summary 		= Faker::Lorem.paragraphs(5).join("\n\n")
				location 		= hash[:location]
				price 			= hash[:price]
				category 		= hash[:desc][:category]
				tags 			= hash[:desc][:tag]
				u.services.create!(title: title, 
										headline: headline, 
										summary: summary, 
										location: location, 
										price: price,
										category: category, 
										tags: tags )
			end
		end
	end

	def populate_user_services
		# Five users
		users = User.limit(5)
		services = Service.limit(10)

		# For each user attach service relationships 
		users.each do |u|
			relationship_type = 'check'
			services.each do |s|
				# Swtich between creating services and pins
				u.user_services.create!(service_id: s.id, relationship_type: relationship_type)
				relationship_type = (relationship_type == 'check') ? 'pin' : 'check'
			end
		end 
	end

	# Random values
	def random_hash
		belt 		= ['white', 'green', 'blue', 'red', 'black'].sample
		location 	= ['Los Angeles', 'USC', 'Southern California', 'Silicon Valley', 'San Francisco', 'Boston', 'United States'].sample
		price 		= [*10..200].sample
		desc 		= [ { title: 'Cheap Guitar Lessons', category: 'Music', tag: 'Guitar', headline: 'Experience professional teaching guitar'},
						{ title: 'Piano Lessons!', category: 'Music', tag: 'Piano', headline: 'Can teach beginners to experienced people'},
						{ title: 'Dog Walking All Day', category: 'Errands', tag: 'Dog Walking', headline: 'I love spending time with dogs!'},
						{ title: 'How to Ride A Bike', category: 'Sports/Fitness', tag:'Biking', headline: 'Teaching you how to ride a bike in one day!'}, 
						{ title: 'BUAD 425 Tutoring Session', category: 'Education', tag: 'Tutoring', headline: 'Helping students with BUAD 425' },
						{ title: 'Joes Car Washing Service', category: 'Errands', tag: 'Car Wash', headline: "We've been doing this for a long time!"} ].sample
		hash 		= { belt: belt, location: location, price: price, desc: desc }

		hash
	end

	def random_belt
		['white', 'green', 'blue', 'red', 'black'].sample
	end
	
	def random_date
		[*1..30].sample.days.from_now.to_date
	end
end














