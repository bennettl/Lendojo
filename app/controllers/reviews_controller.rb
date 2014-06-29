class ReviewsController < ApplicationController
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!
	
	# Include sorting params for sortable headers on index page
	include HeaderFiltersHelper

	# Swagger documentation
	swagger_controller :reviews, "Review operations"

	##################################################### RESOURCES #####################################################

	# Shows a list of reviews
	swagger_api :index do
		summary "Shows a list of reviews"
		param :path, :id, :integer, :required, "Review ID"
	end
	def index
		@reviews = Review.all.order("#{sort_name_param} #{sort_direction_param}").paginate(per_page: 5, page: params[:page])
	end

	# Shows an individual review
	swagger_api :show do
		summary "Shows an individual review"
		param :path, :id, :integer, :required, "Review ID"
	end
	def show
		if @review = Review.find_by(id: params[:id])
			# Respond to different formats
			respond_to do |format|
			  format.html # show.html.erb
			  format.json { render json: @review }
			end
		else
			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to :back }
			  format.json { render json: { message: "Review does not exist" } }
			end
		end
	end

	# Creates a new review
	swagger_api :create do
		summary "Creates a new review"
		notes "current_user is giving the review"
		param :form, :lender_id, :integer, :required, "Lender ID"
		param :form, :title, :string, :required, "Title"
		param :form, :summary, :string, :required, "Summary"
		param :form, :stars, :string, :required, "Stars"
	end
	def create
	    # Create the review
		@review = current_user.reviews_given.create!(review_params)

		# Respond to JSON
		respond_to do |format|
		    format.json  { render json: @review}
		end
	end

	# Destroy an existing review
	swagger_api :destroy do
		summary "Destroy an existing review"
		param :path, :id, :integer, :required, 'Review ID'
	end
	def destroy
		@review = Review.destroy(params[:id])
	    render json: { message: "Review Successfully Destroyed", review: @review }
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

	##################################################### PRIVATE #####################################################

	private 

	# Strong parameters
	def review_params
		params.require(:review).permit(:lender_id, :title, :summary, :stars)
	end

end
