namespace :db do
	desc 'Fill database with sample data' 
	task populate: :environment do
		populate_admin
		populate_users
		populate_services
		populate_filters
		populate_user_services
		populate_lender_applications
		populate_reports
		populate_referrals
		populate_tags
	end	

	# Populate Administrator
	def populate_admin
		User.create!(first_name: 'Bennett',
						last_name: 'Lee',
						headline: "Aspiring Entreprenuer, Veteran Software Developer, Dabbling Musician",
						summary: Faker::Lorem.paragraphs(2).join("\n\n"),
						birthday: Date.strptime("09/08/1992", "%m/%d/%Y"),
						email: 'bennettl@usc.edu',
						phone: '800-123-4567',
						location: 'USC',
						address: '711 W. 27th Street',
						city: 'Los Angeles',
						state: 'CA',
						zip: '90007',
						lender: true,
						belt: 'black',
						status: 'admin',
						password: 'paper',
						password_confirmation: 'paper')

	end
	
	# Populate users
	def populate_users
		# Create 40 users
		40.times do |n|
			first_name 		= Faker::Name.first_name
			last_name 		= Faker::Name.last_name
			headline 		= Faker::Lorem.sentences(1).join(' ')
			summary 	    = Faker::Lorem.paragraphs(2).join("\n\n")
			birthday		= Date.strptime("09/08/1992", "%m/%d/%Y"),
			email			= Faker::Internet.email
			phone			= Faker::Base.numerify('###-###-####')
			location		= Faker::Address.city
			address			= Faker::Address.street_address
			state 			= Faker::Address.state_abbr # CA
			city			= location
			zip 			= Faker::Address.zip_code # 90007
			lender 			= [true, false].sample
			belt 			= (lender) ? random_belt : 'N/A' # don't give user a belt if he's not a lender

			# Create the user
			User.create!(first_name: first_name,
							last_name: last_name,
							headline: headline,
							summary: summary,
							# birthday: birthday,
							email: email,
							phone: phone,
							location: location,
							address: address,
							city: city,
							state: state,
							zip: zip,
							lender: lender, 
							belt: belt,
							password: 'qwerty2',
							password_confirmation: 'qwerty2')
							
		end
	end

	# Populate services and attach ratings/reviews to them
	def populate_services
		users 	= User.limit(5)
		switch	= true

		# Loop through each user
		users.each do |u|
			# Each user will create 8 services
			15.times do |n|
				service_hash 	= random_service_hash
				title 			= "#{n} " + service_hash[:desc][:title]
				headline 		= service_hash[:desc][:headline]
				summary 		= Faker::Lorem.paragraphs(5).join("\n\n")
				price 			= service_hash[:price]
				category 		= service_hash[:desc][:category]
				tags 			= service_hash[:desc][:tag]
				location 		= service_hash[:location]
				address 		= Faker::Address.street_address
				state 			= Faker::Address.state_abbr
				city			= Faker::Address.city
				zip 			= Faker::Address.zip_code
				
				# Create the service
				u.services.create!(title: title, 
										headline: headline, 
										summary: summary, 
										location: location,
										address: address,
										city: city,
										state: state,
										zip: zip,
										price: price,
										category: category, 
										tags: tags )
				# Every other service will get 5 reviews and ratings
				if switch
					review_lender(u)
					switch = false
				else
					switch = true
				end
			end
		end
	end

	# Populate filter data for the first User
	def populate_filters
		user = User.first
		user.filters.create(title: 'USC Music', data: { location: ['USC', 'Los Angeles'], price: ['$', '$$'], keyword: ['guitar', 'piano'] } )
		user.filters.create(title: 'San Francisco Services', data: { location: ['San Francisco', 'Silicon Valley'], price: ['$$', '$$$'] } )
		user.filters.create(title: 'Cheap Pet Services', data: { location: ['Venice', 'Los Angeles'], price: ['$', '$$'], keyword: ['pets'] } )
	end

	# Populate user services relationships (checks/pins)
	def populate_user_services
		# Five users
		users 		= User.limit(5)
		services 	= Service.limit(10)

		# For each user attach service relationships 
		users.each do |u|
			relationship_type = 'check'
			services.each do |s|
				# Swtich between creating services and pins
				u.lendee_user_services.create!(service_id: s.id, 
												lender_id: s.lender.id,
												address: s.address,
												city: s.city,
												state: s.state,
												zip: s.zip,
												relationship_type: relationship_type
												)
				relationship_type = (relationship_type == 'check') ? 'pin' : 'check'
			end
		end 
	end


	# Populate lender_applications
	def populate_lender_applications
		# Only choose users who aren't enders
		users = User.where(lender: false).limit(10)

		# For each user, create a lender application
		users.each do |u|
			keyword 		= ['music', 'education', 'art', 'errands', 'pets', 'sports/fitness'].sample
			skill 			= ['amateur', 'intermediate', 'expert'].sample
			hours 			= [*3...23].sample
			summary 		= Faker::Lorem.sentences(4).join(' ')

			# Method use to create for has_one association
			u.create_lender_app(keyword: keyword, skill: skill, hours: hours, summary: summary)
		end

	end

	# Populate reports for services and users
	def populate_reports
		author_id 		= [*1..40].sample
		summary 		= Faker::Lorem.sentences(3).join(' ')
		reason 			= [*0..4].sample # enum
		
		# Report on other users
		users = User.limit(5)
		users.each do |u|
			u.reports_received.create!(author_id: author_id, reason: reason, summary: summary)
		end

		# Report on other services
		services = Service.limit(5)
		services.each do|s|
			s.reports_received.create!(author_id: author_id, reason: reason, summary: summary)
		end
	end

	# Populat referrals
	def populate_referrals
		user = User.first
		users = User.limit(10)

		# Refer 8 other users
		users.each do |u|
			user.refer!(u) # create the referral
		end
		
	end

	# Populate tags
	def populate_tags
		# Location
		Tag.create!(category: "location", name: "Silicon Valley")
		Tag.create!(category: "location", name: "Southern California")
		Tag.create!(category: "location", name: "Venice")
		Tag.create!(category: "location", name: "Los Angeles")
		Tag.create!(category: "location", name: "Huntington Park")
		Tag.create!(category: "location", name: "Orange County")
		Tag.create!(category: "location", name: "San Jose")
		Tag.create!(category: "location", name: "Mountain View")
		Tag.create!(category: "location", name: "San Francisco")
		Tag.create!(category: "location", name: "Oakland")
		Tag.create!(category: "location", name: "Beverley Hills")
		Tag.create!(category: "location", name: "Hollywood")
		Tag.create!(category: "location", name: "Northern California")
		Tag.create!(category: "location", name: "University of Southern California")
		Tag.create!(category: "location", name: "Santa Monica")
		# Keyword
		Tag.create!(category: "keyword", name: "Dog Walking")
		Tag.create!(category: "keyword", name: "Hair Cutting")
		Tag.create!(category: "keyword", name: "Guitar")
		Tag.create!(category: "keyword", name: "Piano")
		Tag.create!(category: "keyword", name: "Apple")
		Tag.create!(category: "keyword", name: "Surfing")
		Tag.create!(category: "keyword", name: "Skiing")
		Tag.create!(category: "keyword", name: "Basketball")
		Tag.create!(category: "keyword", name: "BUAD 425")
		Tag.create!(category: "keyword", name: "Photos")
		Tag.create!(category: "keyword", name: "Cooking")
		Tag.create!(category: "keyword", name: "Meals")
		Tag.create!(category: "keyword", name: "Computers")
		Tag.create!(category: "keyword", name: "Science")
		Tag.create!(category: "keyword", name: "Rock and Roll")
		# Category
		Tag.create!(category: "category", name: "Music")
		Tag.create!(category: "category", name: "Education")
		Tag.create!(category: "category", name: "Fitness/Sports")
		Tag.create!(category: "category", name: "Errands")
		Tag.create!(category: "category", name: "Freelance")
		Tag.create!(category: "category", name: "Ridesharing")
		Tag.create!(category: "category", name: "Cooking")
		Tag.create!(category: "category", name: "Photography")
		Tag.create!(category: "category", name: "Business")
		Tag.create!(category: "category", name: "Entertainment")
		Tag.create!(category: "category", name: "Technology")
		Tag.create!(category: "category", name: "Finance")
		Tag.create!(category: "category", name: "Dance")
		Tag.create!(category: "category", name: "Art")
		Tag.create!(category: "category", name: "Health")
	end

	########################################## HELPER FUNCTIONS #################################################

	# Pass in a lender to be reviewed
	def review_lender(user)
		5.times do |m|
			author 			= User.all.sample # random author, User.all bad for memory
			reviews_hash 	= random_reviews_hash # generate a radom review (title/stars/summary)
			title 			= reviews_hash[:title]
			stars 			= reviews_hash[:stars]
			summary 		= reviews_hash[:summary]
			category 		= random_category

			# Create rating
			author.ratings_given.create!(lender_id: user.id, stars: stars)
			# Create review
			author.reviews_given.create!(lender_id: user.id,
											title: title, 
											stars: stars,
											summary: summary, 
											category: category)
		end
	end

	# Random hash for service
	def random_service_hash
		belt 		= ['white', 'green', 'blue', 'red', 'black'].sample
		location 	= ['Los Angeles', 'USC', 'Southern California', 'Silicon Valley', 'San Francisco', 'Boston', 'United States'].sample
		price 		= [*10..200].sample
		desc 		= [ { title: 'Cheap Guitar Lessons', category: 'Music', tag: 'Guitar', headline: 'Experience professional teaching guitar'},
						{ title: 'Piano Lessons!', category: 'Music', tag: 'Piano', headline: 'Can teach beginners to experienced'},
						{ title: 'Rock and Roll!', category: 'Music', tag: 'Guitar', headline: 'Teaching rock and rock style guitar'},
						{ title: 'Dog Walking All Day', category: 'Errands', tag: 'Dog Walking', headline: 'I love spending time with dogs!'},
						{ title: 'How to Ride A Bike', category: 'Sports/Fitness', tag:'Biking', headline: 'Teaching you how to ride a bike!'}, 
						{ title: 'BUAD Tutor Session', category: 'Education', tag: 'Tutoring', headline: 'Helping students with BUAD 425' },
						{ title: 'Car Washing Service', category: 'Errands', tag: 'Car Wash', headline: "We've been doing this for a long time!"} ].sample
		hash 		= { belt: belt, location: location, price: price, desc: desc }

		hash
	end


	# Helper function for generating random reviews
	def random_reviews_hash
		[{title: "Pretty decent, could have been better", stars: 4, summary: "This chair arrived well-packaged and protected with a lot of foam insulation around the wheels and metal components. Assembly was quick and simple, as I didn't even need the instructions. All you have to do is put the air lift on the base and place the seat on the air lift, then it's ready to go. The chair has great lumbar support and reaches all the way up to my head, allowing me to rest entirely against it. It's also fairly comfortable, having a few inches of padding, while not being too compliant so as to lack support, making for a pretty good balance that I particularly like. The air lift lever (for raising/lowering the height of the chair) is designed so that when pushed in the chair cannot recline, but if you pull it out slightly, it releases a mechanical lock and allows the chair to recline back about 20-30 degrees."},
		{title: "Got exactly what I needed and more!", stars: 5, summary: "Customer Service: We often encounter a customer service rep who has had a bad day or just does not care or any of the negative phrases that make us some reps. This is absolutely NOT the case with the folks at BOSS. After opening the box and putting it together (a feat accomplished by anyone who can lift a sack of potatoes) I could not get the gas cylinder to raise the seat level. One of us is 5'6\" and the other is 6'3\" and the seat is either too high or too low unless the gas cylinder works. It did not. 

				It was too late to call and it was Thanksgiving eve. Even if anyone had been home I would have waited until Frantic Friday to call. So I emailed my concern and expected no reply until today or maybe tomorrow. On Friday, the 26th, the height adjustment absence was just too much to endure. A call was placed to BOSS and a woman told me exactly what to do and I did. Closed case. Wow! I did suggest that the instructions would benefit from her advice in future iterations. Regardless, my problem was settled in seconds and when I finally got to reviewing my email I saw a response from BOSS saying the same thing. Let's all give a big shout to BOSS for fantastic service."
		},
		{title: "Quick, Easy, and Fast!", stars: 4, summary: "The chair leans back which is nice. Doesn't seem to have too much lean which i don't really like but it's enough to put my feet up on my sub woofer. The leather is very nice quality and it has a built-in lumbar support which feels nice. My only issue with the chair was the first chair i sat in it and a bolt sheered off. But i told amazon and they had my new chair their the next day (same as what i paid for to ship it originally) and they had a ups man there the next day to pick up the broken chair. After that the chair has been flawless and very comfortable. The leather feels less cheap then the leather on my old chair."
			},
			{title: "Bad Overall Experience", stars: 2 , summary: "This chair is nicely built. It looks elegant and cool. It is easy to clean.
				The problem for me is that this is too big.
				I am male, 170 cm, 56 kg, that is about 5 foot 7 inches and 123 pounds. I don't feel very comfortable in this chair especially due to the armrest. The armrest is just a few centimeters too high, it pushes my elbow up, and that's annoying.
				The part where you sit on is very large, and I seem to \"sink\" inside it, which worsens the armrest problem.
				But I think if you are taller, this should be good. It will be even better if you are both taller and fatter. Maybe if I were 180cm(5 foot 11 inches) 85kg(188 pounds), this chair would be perfect." },
							{title: "Worse Lender In Dojo!", stars: 1, summary: "First the positives:

				* This is the easiest chair I've ever put together. Simply unfold the chair back and the seat, which come pre-attached along with the arms, until they lock together. Next, place the gas cylinder firmly into the chair base and snap the 5 wheels onto the bottom. Finally, slide the gas cylinder/base into the seat bottom. It's completely tool-less and takes minutes.

				* The chair itself is pretty comfortable. It fit my back perfectly and was firm enough to give support while being soft enough to sit for extended periods.

				* Contrary to what other reviewers say, this chair can lean back. Just slide the height adjustment lever in towards the chair to lock the back in place, or slide it out to allow the chair to lean backwards."
		},
		{title: "The Best Lender In the Dojo!", stars: 5, summary: "Purchased this chair once before on July 26, 2012. Was happy with the chair and the material that was used. This time the material was totally different. Very Cheap, so called Leather Plus..................... Very Cheap. In the description it does say Leather Plus but in the details as this is how it is described, below. I copied and pasted the information. It is not Leather............. Don't be fooled and it feels and looks very cheap. This material is totally different from the purchase in the past. If it were the same as the first chair I bought, I would have been happy. It was discribe to be the exact same and was not............ I don't write many reviews and I shop a lot with Amazon and this time I am a very unhappy shopper. Beware of this cheap chair..........................................."
		},
		{title: "Very good experience", stars: 4, summary: "This chair was packed sufficiently, arrived quickly, and was easy to assemble (5mins, no tools). The chair is comfortable, but I'll have to either turn my A/C colder or wear a shirt (I work at home) because this material either makes me sweat a lot more, or it just shows up more."
		},
		{title: "Experienced teach, but always late", stars: 2, summary: "Update: after less that 1 year of use, this chair's piston is giving out. It rises on it's own, and I have to lower the chair every time I sit in it. It even rises slowly while I am in it, causing me to have to constantly lower it again. CHEAP CRAP!!!"
		}].sample
	end


	def random_category
		['errands', 'music', 'education', 'art', 'pets', 'fitness'].sample
	end

	# Returns a random user between ID 1..40
	def random_user
		User.find([*1..40].sample)
	end
	
	def random_belt
		['white', 'green', 'blue', 'red', 'black'].sample
	end
	
	def random_date
		[*1..30].sample.days.from_now.to_date
	end
end














