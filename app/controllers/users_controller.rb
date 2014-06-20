class UsersController < ApplicationController

	# List all users
	def index
		@users = User.search(search_params).paginate(per_page: 5, page: params[:page])
	end

	# Show individual user
	def show
		@user = User.find(params[:id])
	end

	# Display form to create a new user
	def new
		@user = User.new
	end

	# Create a new user
	def create
		@user = User.new(user_params_post)
		if @user.save
			flash[:success] = "User Sucessfully Created"
			redirect_to new_user_path
		else
			render 'new'
		end
	end

	# Display form for updating an existing user
	def edit
		@user = User.find(params[:id])
	end

	# Update an existing user
	def update
		@user = User.find(params[:id])
		
		# If update is sucessful, redirect to user page, else render edit page
		if @user.update_attributes(user_params)
			flash[:success] = "Update is successful"
			redirect_to edit_user_path(@user)
		else
			render 'edit'
		end
	end

	# Displays the form for creating both a rating AND a review
	def new_rating
		@user 	= User.find(params[:id])
		@rating = Rating.new
		@review = Review.new
	end

	# Update a user's credit card information
	def update_card
		# Get the credit card details submitted by the form or app
		token = params[:stripeToken]

		# Create a Customer
		customer = Stripe::Customer.create(
		  :card => token,
		  :description => current_user.email,
		  :email => current_user.email
		)

		# Charge the Customer instead of the card
		# Stripe::Charge.create(
		#     :amount => 1000, # in cents
		#     :currency => "usd",
		#     :customer => customer.id
		# )

		# save the customer ID in your database so you can use it later
		if current_user.update_attribute(:stripe_customer_id, customer.id)
			flash[:success] = 'Credit Card Sucessfully Updated!'
		else
			flash[:error] = 'Unable to update Credit Card'
		end

		redirect_to edit_user_path(current_user)
	end

	# Destroy an existing user
	def destroy
		User.delete(params[:id])
		flash[:success] = 'User Sucessfully Destroyed'
		redirect_to users_path
	end


	# Display a list of services user has checked
	def checklist

		@lendee_checkList = current_user.lendee_check_user_services

		if current_user.lender?
			@lender_checkList = current_user.lender_check_user_services
		end

	end

	# Display a list of services user had pinned
	def pins
		@services = current_user.lendee_pins
	end

	# Report an existing user
	def report
		@user = User.find(params[:id])
	end


	# Autocompletion
	def autocomplete
		# Default values
		column 	= params[:column] || 'major'
		value 	= params[:value] || '5'
		# Select unique column values base on value variable
		users 	= User.select(column).where("#{column} LIKE '%#{value}%'").uniq
		# Only get the column value (not the id) in the users set
		result 	= users.collect do |u|
			    	u[column].to_s
			    end
		# Return a JSON formatted data
		render json: result
	end

	private
		
		# Strong parameters
		def search_params
			params.permit(:name)
		end
		
		def user_params
			params.require(:user).permit(:main_img, :first_name, :last_name, :headline, :age, :email, :phone, :lender, :summary, :location, :city, :state, :zip, :stripe_customer_id, :password, :password_confirmation)
		end
end
