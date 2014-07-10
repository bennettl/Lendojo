class ReferralsController < ApplicationController
		##################################################### FILTERS #####################################################
	
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!

	##################################################### SWAGGER #####################################################

	# Swagger documentation
	swagger_controller :referrals, "Referral operations"

	##################################################### RESOURCES #####################################################
	
	# Shows a list of referrals
	swagger_api :index do
		summary "Shows a list of referrals"
		param :path, :id, :integer, :required, "Referral ID"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		@referrals = Referral.all.order("created_at desc").paginate(per_page: 5, page: params[:page])
		# JRespond to JSON
		# Respond to different formats
		respond_to do |format|
			format.html # index.html.erb
			format.js # index.js.erb
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
		param :path, 	:id, :integer, 		:required, "Lender ID"
		param :query, 	:author_id, 		:integer, :required, "Author ID"
		param :form, 	'referral[stars]', 	:integer, :required, "Stars"
	end
	def create
		@lender = User.find_by(id: params[:id])
		@author = User.find_by(id: params[:author_id])

		if @referral = @author.rate!(@lender, referral_params)
			flash[:success] = "Thanks for your feedback!"
			
			# Respond to different formats
			respond_to do |format|
				format.html { redirect_to checklist_users_path }
			    format.json  { render json: @referral }
			end
		else
			flash[:error] = @referral.errors.full_messages
			# Respond to different formats
			respond_to do |format|
				format.html { redirect_to checklist_users_path }
			    format.json  { render json: { message: "Unable to create referral", error: flash[:error] } }
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
