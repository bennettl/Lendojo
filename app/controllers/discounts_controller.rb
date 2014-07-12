class DiscountsController < ApplicationController
##################################################### FILTERS #####################################################
	
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!
	
	# Include sorting params for sortable headers on index page
	include HeaderFiltersHelper

	##################################################### SWAGGER #####################################################

	swagger_controller :discounts, "Discount operations"

	##################################################### RESOURCES #####################################################

	# Shows a list of discounts
	swagger_api :index do
		summary "Shows a list of discounts"
		param :path, :id, :integer, :required, "Discount ID"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		@discounts = Discount.all.order("#{sort_name_param} #{sort_direction_param}").paginate(per_page: 5, page: params[:page])
		# Respond to different formats
		respond_to do |format|
			format.html # index.html.erb
			format.js # index.js.erb
			format.json { render json: @discounts }
		end
	end

	# Shows an individual discount
	swagger_api :show do
		summary "Shows an individual discount"
		param :path, :id, :integer, :required, "Discount ID"
	end
	def show
		if @discount = Discount.find_by(id: params[:id])
			# Respond to different formats
			respond_to do |format|
			  format.html # show.html.erb
			  format.json { render json: @discount }
			end
		else
			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to :back }
			  format.json { render json: { message: "Discount does not exist" } }
			end
		end
	end


	# Creates a new discount
	swagger_api :create do
		summary "Creates a new discount"
		param :path, 	:id, 				:integer,	:required, "Lender ID"
		param :query, 	:author_id, 		:integer, 	:required, "Author ID"
		param :form, 	'discount[title]', 	:string, 	:required, "Title"
		param :form, 	'discount[summary]', 	:string, 	:required, "Summary"
		param :form, 	'discount[stars]', 	:string, 	:required, "Stars"
	end
	def create
	    @lender = User.find_by(id: params[:id])
		@author = User.find_by(id: params[:author_id])

		# Rating responds to HTML discounts will respond with JSON
		if @discount = @author.discount!(@lender, discount_params)
			render json: @discount
		else
			render json:  {message: "Unable to create discount", error: @discount.errors.full_messages }
		end
		
	end

	# Destroy an existing discount
	swagger_api :destroy do
		summary "Destroy an existing discount"
		param :path, :id, :integer, :required, 'Discount ID'
	end
	def destroy
		if @discount = Discount.find_by(id: params[:id])
			render json: @discount.destroy
		else
			render json: { message: "Discount Not Found" }
		end
	end

	# Update the voute count
	def vote
		@discount = Discount.find(params[:id])

		if params[:type] == 'up'
			@discount.add_or_update_evaluation(:up_votes, 1, current_user)
		end

		# Both up and down votes affect total votes
		@discount.add_or_update_evaluation(:total_votes, 1, current_user)
		
		flash[:success] = "Thanks for voting!"
		redirect_to :back
	end

	##################################################### PRIVATE #####################################################

	private 

	# Strong parameters
	def discount_params
		params.require(:discount).permit(:lender_id, :title, :summary, :stars)
	end
end
