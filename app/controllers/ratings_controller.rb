class RatingsController < ApplicationController
	##################################################### FILTERS #####################################################
	
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!

	##################################################### SWAGGER #####################################################

	# Swagger documentation
	swagger_controller :ratings, "Rating operations"

	##################################################### RESOURCES #####################################################
	
	# Shows a list of ratings
	swagger_api :index do
		summary "Shows a list of ratings"
		param :path, :id, :integer, :required, "Rating ID"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		@ratings = Rating.all.order("created_at desc").paginate(per_page: 5, page: params[:page])
		# JRespond to JSON
		render json: @ratings
	end

	# Shows an individual rating
	swagger_api :show do
		summary "Show indivdual rating"
		param :path, :id, :integer, :required, "Rating ID"
	end
	def show
		if @rating = Rating.find_by(id: params[:id])
			# Respond to different formats
			respond_to do |format|
			  format.html # show.html.erb
			  format.json { render json: @rating }
			end
		else
			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to :back }
			  format.json { render json: { message: "Rating does not exist" } }
			end
		end
	end

	# Creates a new rating
	swagger_api :create do
		summary "Creates a new rating"
		param :path, 	:id, :integer, 		:required, "Lender ID"
		param :query, 	:author_id, 		:integer, :required, "Author ID"
		param :form, 	'rating[stars]', 	:integer, :required, "Stars"
	end
	def create
		@lender = User.find_by(id: params[:id])
		@author = User.find_by(id: params[:author_id])

		if @rating = @author.rate!(@lender, rating_params)
			flash[:success] = "Thanks for your feedback!"
			
			# Respond to different formats
			respond_to do |format|
				format.html { redirect_to checklist_users_path }
			    format.json  { render json: @rating }
			end
		else
			flash[:error] = @rating.errors.full_messages
			# Respond to different formats
			respond_to do |format|
				format.html { redirect_to checklist_users_path }
			    format.json  { render json: { message: "Unable to create rating", error: flash[:error] } }
			end
		
		end
	end


	# Destroy an existing rating
	swagger_api :destroy do
		summary "Destroy an existing rating"
		param :path, :id, :integer, :required, 'Rating ID'
	end
	def destroy
		if @rating = Rating.find_by(id: params[:id])
			render json: @rating.destroy
		else
			render json: { message: "Rating Not Found" }
		end
	end

	##################################################### PRIVATE #####################################################

	private

	# Strong parameters
	def rating_params
		params.require(:rating).permit(:stars)
	end

end
