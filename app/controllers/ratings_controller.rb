class RatingsController < ApplicationController
	
	# Swagger documentation
	swagger_controller :ratings, "Ratings"

	# Creates a new rating
	def create
	    msg = { status: "Rating Created!" }

	    # Create the rating
		current_user.ratings_given.create!(rating_params)
		
		# Respond with JSON
		# respond_to do |format|
		#     format.json  { render :json => msg }
		# end

		# Once a ratings is created, it will direct user back to checklist_users_path
		flash[:success] = "Thanks for your rating!"
		redirect_to checklist_users_path
	end

	private

	# Strong parameters
	def rating_params
		params.require(:rating).permit(:lender_id, :stars)
	end

end
