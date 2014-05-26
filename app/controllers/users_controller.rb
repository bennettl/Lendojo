class UsersController < ApplicationController

	# List all users
	def index
		# @users = User.all.paginate(per_page: 5, page: params[:page])
		@users = User.all
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
		if @user.update_attributes(user_params_post)
			flash[:success] = "Update is sucessful"
			redirect_to @user
		else
			render 'edit'
		end
	end

	# Destroy an existing user
	def destroy
		User.delete(params[:id])
		flash[:success] = 'User Sucessfully Destroyed'
		redirect_to users_path
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
		
		def user_params_post
			params.require(:user).permit(:user_type, :status, :email, :user_name, :first_name, :last_name, :major, :city, :class_year, :industry, :password, :password_confirmation)
		end

		def user_params
			params.permit(:first_name, :last_name, :city, :industry, :major, :class_year, :password, :password_confirmation)
		end
end
