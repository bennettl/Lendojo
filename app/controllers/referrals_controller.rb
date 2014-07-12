class ReferralsController < ApplicationController
	##################################################### FILTERS #####################################################
	
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!

	# Include sorting params for sortable headers on index page
	include HeaderFiltersHelper
	
	##################################################### SWAGGER #####################################################

	# Swagger documentation
	swagger_controller :referrals, "Referral operations"

	##################################################### RESOURCES #####################################################
	
	# Shows a list of referrals
	swagger_api :index do
		summary "Shows a list of referrals"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		@referrals = Referral.all.order("#{sort_name_param} #{sort_direction_param}").paginate(per_page: 5, page: params[:page])
		# JRespond to JSON
		# Respond to different formats
		respond_to do |format|
			format.html # index.html.erb
			format.js # index.js.erb
			format.json { render json: @referrals }
		end
	end

	# Shows a list of referrals for a particular user
	swagger_api :user_index do
		summary "Shows a list of referrals"
		param :path, :id, :integer, :required, "Referrer ID"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def user_index
		@referrals = Referral.where(referrer_id: params[:id]).order("updated_at DESC").paginate(per_page: 5, page: params[:page])
		# JRespond to JSON
		# Respond to different formats
		respond_to do |format|
			format.html # user_index.html.erb
			format.js # user_index.js.erb
			format.json { render json: @referrals }
		end
	end

	# Shows an individual referral
	swagger_api :show do
		summary "Show indivdual referral"
		param :path, :id, :integer, :required, "Referral ID"
	end
	def show
		if @referral = Referral.find_by(id: params[:id])
			# Respond to json
			render json: @referral
		else
			render json: { message: "Referral does not exist" }
		end
	end

	# Creates a new referral
	swagger_api :create do
		summary "Creates a new referral"
		param :path, 	:id, :integer, 		:required, "Referrer ID"
		param :query, 	:referree_id, 		:integer, :required, "Referree ID"
	end
	def create
		@referrer = User.find_by(id: params[:id])
		@referee  = User.find_by(id: params[:referree_id])

		if @referral = @referrer.referrals.create!(@lender, referral_params)
			flash[:success] = "Thanks for your feedback!"
			
			# Respond to JSON formats
			respond_to do |format|
			    format.json  { render json: @referral }
			end
		else
			flash[:error] = @referral.errors.full_messages
			# Respond to JSON formats
			respond_to do |format|
			    format.json  { render json: { message: "Unable to create referral", error: flash[:error] } }
			end
		
		end
	end

	# Update an existing referral
	swagger_api :update do
		summary "Update an existing referral"
		param :path, 		'id',						:integer, :required, "Referral ID"
		param_list :form, 	'referral[status]', 		:status,  :optional, "Status", Referral.statuses.keys
	end
	def update
		@referral = Referral.find_by(id: params[:id])

		if @referral.update_attribute('status', params[:referral][:status])
			flash[:success] = "Referral sucessfully updated!"
			# Respond to JSON format
			respond_to do |format|
			    format.json { render json: @referral }
			end
		else
			flash[:error] = @referral.errors.full_messages
			# Respond to multiple formats
			respond_to do |format|
			    format.json { render json: { message: "Referral Update Was Not sucessful", error: flash[:error] } }
			end
			
		end
	end

	# Destroy an existing referral
	swagger_api :destroy do
		summary "Destroy an existing referral"
		param :path, :id, :integer, :required, 'Referral ID'
	end
	def destroy
		if @referral = Referral.find_by(id: params[:id])
			render json: @referral.destroy
		else
			render json: { message: "Referral Not Found" }
		end
	end

	##################################################### PRIVATE #####################################################

	private

	# Strong parameters
	def referral_params
		params.require(:referral).permit(:referrer_id, :referree_id)
	end
end
