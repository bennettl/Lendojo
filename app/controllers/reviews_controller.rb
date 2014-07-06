class ReviewsController < ApplicationController
	
	##################################################### FILTERS #####################################################
	
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!
	
	# Include sorting params for sortable headers on index page
	include HeaderFiltersHelper

	##################################################### SWAGGER #####################################################

	swagger_controller :reviews, "Review operations"

	##################################################### RESOURCES #####################################################

	# Shows a list of reviews
	swagger_api :index do
		summary "Shows a list of reviews"
		param :path, :id, :integer, :required, "Review ID"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		@reviews = Review.all.order("#{sort_name_param} #{sort_direction_param}").paginate(per_page: 5, page: params[:page])
		# Respond to different formats
		respond_to do |format|
			format.html # index.html.erb
			format.js # index.js.erb
			format.json { render json: @reviews }
		end
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
		param :path, 	:id, 				:integer,	:required, "Lender ID"
		param :query, 	:author_id, 		:integer, 	:required, "Author ID"
		param :form, 	'review[title]', 	:string, 	:required, "Title"
		param :form, 	'review[summary]', 	:string, 	:required, "Summary"
		param :form, 	'review[stars]', 	:string, 	:required, "Stars"
	end
	def create
	    @lender = User.find_by(id: params[:id])
		@author = User.find_by(id: params[:author_id])

		# Rating responds to HTML reviews will respond with JSON
		if @review = @author.review!(@lender, review_params)
			render json: @review
		else
			render json:  {message: "Unable to create review", error: @review.errors.full_messages }
		end
		
	end

	# Destroy an existing review
	swagger_api :destroy do
		summary "Destroy an existing review"
		param :path, :id, :integer, :required, 'Review ID'
	end
	def destroy
		if @review = Review.find_by(id: params[:id])
			render json: @review.destroy
		else
			render json: { message: "Review Not Found" }
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

	##################################################### PRIVATE #####################################################

	private 

	# Strong parameters
	def review_params
		params.require(:review).permit(:lender_id, :title, :summary, :stars)
	end

end
