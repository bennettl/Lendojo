class RatingsController < ApplicationController
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!
	
	# Swagger documentation
	swagger_controller :ratings, "Rating operations"

	##################################################### RESOURCES #####################################################
	
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
		summary "Creates A New Rating"
		notes "current_user is giving the rating"
		param :form, :lender_id, :integer, :required, "Lender ID"
		param :form, :stars, :integer, :required, "Stars"
	end
	def create
		# Once a ratings is created, it will direct user back to checklist_users_path
		flash[:success] = "Thanks for your rating!"

	    # Create the rating
		@rating = current_user.ratings_given.create!(rating_params)
		
		# Respond to different formats
		respond_to do |format|
			format.html { redirect_to checklist_users_path }
		    format.json  { render json: @rating }
		end
	end


	# Destroy an existing rating
	swagger_api :destroy do
		summary "Destroy an existing rating"
		param :path, :id, :integer, :required, 'Rating ID'
	end
	def destroy
		@rating = Rating.destroy(params[:id])
	    render json: { message: "Rating Successfully Destroyed", rating: @rating }
	end

	##################################################### PRIVATE #####################################################

	private

	# Strong parameters
	def rating_params
		params.require(:rating).permit(:lender_id, :stars)
	end

end
