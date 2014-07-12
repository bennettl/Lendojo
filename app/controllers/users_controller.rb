class UsersController < ApplicationController
	
	##################################################### FILTERS #####################################################
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!

	# Check to see if user signed up is complete before accessing actions of controller
	before_filter :ensure_signup_complete, except: [:update]

	# Include sorting params for sortable headers on index page
	include HeaderFiltersHelper
	
	##################################################### SWAGGER #####################################################

	swagger_controller :users, "User operations"

	##################################################### RESOURCES #####################################################

	# Show all users
	swagger_api :index do
		summary "Show all users"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		@users = User.search(search_params).order("#{sort_name_param} #{sort_direction_param}").paginate(per_page: 5, page: params[:page])
		
		# Respond to different formats
		respond_to do |format|
		  format.html # index.html.erb
		  format.js  # index.js.erb
		  format.json { render json: @users }
		end
	end	

	# Show an individual user
	swagger_api :show do 
		summary "Show an individual user"
	    param :path, :id, :integer, :required, "User ID"
	end
	def show
		if @user = User.find_by(id: params[:id])
			@reviews = @user.reviews_recieved.paginate(per_page: 4, page: params[:review_page])
			# Respond to different formats
			respond_to do |format|
			  format.html # show.html.erb
			  format.js # show.js.erb
			  format.json { render json: @user }
			end
		else
			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to :back }
			  format.json { render json: { message: "User does not exist" } }
			end
		end
	end
	
	# Display form to create a new user
	def new
		@user = User.new
	end

	# Create a new user
	swagger_api :create do
		summary "Create a new user"
		param :form, 'user[first_name]', 			:string, :required, "First Name"
	    param :form, 'user[last_name]', 			:string, :required, "Last Name"
		param :form, 'user[email]', 				:string, :required, "Email"
		param :form, 'user[phone]', 				:string, :required, "Phone"
		param :form, 'user[city]', 					:string, :required, "City" 
		param :form, 'user[state]', 				:string, :required, "State"
		param :form, 'user[zip]', 					:string, :required, "Zip"
		param :form, 'user[password]', 				:string, :required, "Password"
		param :form, 'user[password_confirmation]', :string, :required, "Password Confirmation"
	end
	def create
		@user = User.new(user_params)
		
		if @user.save
			flash[:success] = "User Sucessfully Created"
			
			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to finish_signup_user(@user) }
			  format.json { render json: { message: "User Sucessfully Created", user: @user } }
			end
			
		else
			flash[:error] = @user.errors.full_messages
			# Respond to different formats
			respond_to do |format|
			  format.html { render 'new' }
			  format.json { render json: { message: "User Was Not Sucessfully Created", error: flash[:error] } }
			end
			
		end
	end	

	# Display form for finishing user signup for unfinished fields
	def finish_signup
		@user = User.find(params[:id])
	end
	
	# Display form for updating an existing user
	def edit
		@user = User.find(params[:id])
	end

	# Update an existing user
	swagger_api :update do
		summary "Update an existing user"
		param :path, :id, :integer, :required, "User ID"
		param :form, 'user[first_name]', :string, :optional, "First Name"
	    param :form, 'user[last_name]', :string, :optional, "Last Name"
		param :form, 'user[headline]', :string, :optional, "Headline"
		param :form, 'user[summary]', :string, :optional, "Summary"
		param :form, 'user[age]', :string, :optional, "Age"
		param :form, 'user[city]', :string, :optional, "City" 
		param :form, 'user[state]', :string, :optional, "State"
		param :form, 'user[zip]', :string, :optional, "Zip"
		param :form, 'user[email]', :string, :optional, "Email"
		param :form, 'user[phone]', :string, :optional, "Phone"
		param :form, 'user[lender]', :boolean, :optional, "Lender"
		param :form, 'user[password]', :string, :optional, "Password"
		param :form, 'user[password_confirmation]', :string, :optional, "Password Confirmation"
	end
	def update
		@user = User.find(params[:id])
		
		# If update is sucessful, redirect to user page, else render edit page
		if @user.update_attributes(user_params)
			flash[:success] = "Update Is Successful"

			# If email changed, sign the user in with new credentials
			unless user_params[:email].nil?
				sign_in @user
			end

			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to edit_user_path(@user) }
			  format.json { render json: { message: flash[:success] , user: @user } }
			end
		else
			flash[:error] = @user.errors.full_messages
			# Respond to different formats
			respond_to do |format|
			  format.html { render 'edit' }
			  format.json { render json: { message: "User Update Not Sucessful ", error: flash[:error] } }
			end
			
		end
	end	

	# Displays the form for creating both a rating AND a review
	def feedback
		@lender	= User.find_by(id: params[:id])
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
	swagger_api :destroy do
		summary "Destroy an existing user"
	    param :path, :id, :integer, :required, "User ID"
	end
	def destroy
		if @user = User.find_by(id: params[:id])
			render json: @user.destroy
		else
			render json: { message: "User Not Found" }
		end
	end	

	##################################################### CHECKLIST/PINS #####################################################

	# Display a list of services user has checked
	swagger_api :checklist do
		summary "Show a list of services user has checked"
		param :path, :id, :integer, :required, "User ID"
		param :query, :lendee_page, :integer, :optional, "Lendee Page Number"
		param :query, :lender_page, :integer, :optional, "Lender Page Number"
	end
	def checklist
		@user = User.find_by(id: params[:id])
		@lendee_checkList = @user.lendee_check_user_services.paginate(per_page: 8, page: params[:lendee_page])

		if @user.lender?
			@lender_checkList = @user.lender_check_user_services.paginate(per_page: 8, page: params[:lender_page])
		end
		
		# Respond to different formats
		respond_to do |format|
			format.html # checklist.html.erb
			format.json { render json: { lendee_checkList: @lendee_checkList, lender_checkList: @lender_checkList } }
		end
	end

	# Display a list of services user had pinned
	swagger_api :pins do
		summary "Show a list of services user has pinned"
		param :path, :id, :integer, :required, "User ID"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def pins
		@user 		= User.find_by(id: params[:id])
		@services 	= @user.lendee_pins.paginate(per_page: 8, page: params[:page])
		# Respond to different formats
		respond_to do |format|
			format.html # pins.html.erb
			format.json { render json: @services }
		end
	end

	##################################################### PRIVATE #####################################################

	private
		
	# Search parameters
	def search_params
		params.permit(:name)
	end
	
	# Strong Parameters
	def user_params
		params.require(:user).permit(:main_img, :first_name, :last_name, :headline, :age, :email, :phone, :lender, :summary, :location, :address, :city, :state, :zip, :stripe_customer_id, :password, :password_confirmation)
	end
end
