class ReviewsController < ApplicationController
		
	# Include sorting params for sortable headers on index page
	include HeaderFiltersHelper

	# Swagger documentation
	swagger_controller :reviews, "Reviews"

	# Displays a list of reviews
	def index
		@reviews = Review.all.order("#{sort_name_param} #{sort_direction_param}").paginate(per_page: 5, page: params[:page])
	end

	# Displays an individual review
	def show
		@review = Review.find(params[:id])
	end

	# Creates a new review
	def create
	    msg = { status: "Review Created!" }

	    # Create the review
		current_user.reviews_given.create!(review_params)

		# Respond with JSON
		respond_to do |format|
		    format.json  { render :json => msg }
		end
	end

	# Update the voute count
	def vote
		@review = Review.find(params[:id])

		if params[:type] == 'up'
			@review.add_or_update_evaluation(:up_votes, 1, current_user)
		end

		# Both up and down votes affect total votes
		@review.add_or_update_evaluation(:total_votes, 1, current_user)
		
		flash[:success] = "Thanks for voting!"
		redirect_to :back
	end

	private 

	# Strong parameters
	def review_params
		params.require(:review).permit(:title, :summary, :stars, :lender_id)
	end

end
