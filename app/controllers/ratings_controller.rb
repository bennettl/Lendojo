class RatingsController < ApplicationController
	
	# Swagger documentation
	swagger_controller :ratings, "Rating operations"

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

	private

	# Strong parameters
	def rating_params
		params.require(:rating).permit(:lender_id, :stars)
	end

end
