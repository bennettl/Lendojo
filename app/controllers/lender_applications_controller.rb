class LenderApplicationsController < ApplicationController

	##################################################### FILTERS #####################################################

	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!
	
	# Check to see if user signed up is complete before accessing actions of controller
	before_filter :ensure_signup_complete

	# Include sorting params for sortable headers on index page
	include HeaderFiltersHelper
	
	##################################################### SWAGGER #####################################################

	swagger_controller :lender_applications, "Lender Application operations"

	##################################################### RESOURCES #####################################################

	# Shows a list of lender applications
	swagger_api :index do
		summary "Show a lists of all lender applications"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		@lenderApps = LenderApplication.all.order("#{sort_name_param} #{sort_direction_param}").paginate( per_page: 5, page: params[:page] )
		
		# Respond to multiple formats
		respond_to do |format|
		    format.html # index.html.erb
		    format.js # index.js.erb
		    format.json { render json: @lenderApps }
		end
	end

	# Shows an individual lender application
	swagger_api :show do
		summary "Show indivdual lender applications"
		param :path, :id, :integer, :required, "Lender Application ID"
	end
	def show
		if @lenderApp = LenderApplication.find_by(id: params[:id])
			# Respond to different formats
			respond_to do |format|
			  format.html # show.html.erb
			  format.json { render json: @lenderApp }
			end
		else
			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to :back }
			  format.json { render json: { message: "Lender Application does not exist" } }
			end
		end
	end

	# Displays a form for 
	def new
		@lenderApp = LenderApplication.new
	end

	# Creates a new lender application
	swagger_api :create do
		summary "Create a new lender application"
		param :query, 'author_id', :integer, :required, "Author ID"
		param :form, 'lender_application[categories]', :string, :required, "Categories"
		param :form, 'lender_application[skill]', :string, :required, "Skill"
		param :form, 'lender_application[hours]', :integer, :required, "Hours"
		param :form, 'lender_application[summary]', :string, :required, "Summary"
	end
	def create
		user 		= User.find_by(id: params[:author_id])
		@lenderApp 	= user.build_lender_app(lender_application_params)

		# If a new lenderApp is sucessfully save, redirect ot services index path, else re-render new
		if @lenderApp.save
			flash[:success] = "Thanks for the application! We will get back to you shortly."
			# Notify admin that a new application has been submitted
			LenderApplicationsMailer.created(@lenderApp).deliver
			
			# Respond to multiple formats
			respond_to do |format|
			    format.html { redirect_to services_path }
			    format.json { render json: @lenderApp }
			end
		else
			flash[:error] = @lenderApp.errors.full_messages
			
			# Respond to multiple formats
			respond_to do |format|
			    format.html { render 'new' }
			    format.json { render json: { message: "Lender Application Update Was Not Successful", error: flash[:error] } }
			end
		end
	end

	# Displays a form to update lender application
	def edit
		@lenderApp = LenderApplication.find(params[:id])
	end

	# Update an existing lender application
	swagger_api :update do
		summary "Update an existing lender application"
		param :path, 		'id', 								:integer, :required, "Application ID"
		param :form, 		'lender_application[categories]', 	:string,  :optional, "Categories"
		param :form, 		'lender_application[skill]', 		:string,  :optional, "Skill"
		param :form, 		'lender_application[hours]', 		:integer, :optional, "Hours"
		param :form, 		'lender_application[summary]', 		:string,  :optional, "Summary"
		param_list :form, 	'lender_application[status]', 		:status,  :optional, "Status", LenderApplication.statuses.keys
		param :form, 		'lender_application[staff_notes]', 	:string,  :optional, "Staff Notes"
	end
	def update
		@lenderApp = LenderApplication.find_by(id: params[:id])

		# Change the user's lender status base on the lender application status
		data = (params[:lender_application][:status] == 'approved') ? { lender: true, belt: 'white'} : { lender: false, belt: 'N/A' } 

		# If lenderApp AND lender is sucessfully updated, redirect to index path, else re-render edit
		if @lenderApp.update_attributes(lender_application_params) && @lenderApp.author.update_attributes(data)
			flash[:success] = "Application has been successfully updated!"
			
			# Notify user if status is approved or denied
			if @lenderApp.approved? || @lenderApp.denied?
				LenderApplicationsMailer.updated(@lenderApp).deliver
			end

			# Respond to multiple formats
			respond_to do |format|
			    format.html { redirect_to lender_applications_path }
			    format.json { render json: @lenderApp }
			end
		else
			flash[:error] = @lenderApp.errors.full_messages
			# Respond to multiple formats
			respond_to do |format|
			    format.html { render 'edit' }
			    format.json { render json: { message: "Lender Application Update Was Not Successful", error: flash[:error] } }
			end
		end

	end

	# Destroy an existing lender application
	swagger_api :destroy do
		summary "Destroy an existing lender application"
		param :path, :id, :integer, :required, 'Lender Application ID'
	end
	def destroy
		if @lenderApp = LenderApplication.find_by(id: params[:id])
			render json: @lenderApp.destroy
		else
			render json: { message: "Lender Application Not Found" }
		end
	end

	##################################################### PRIVATE #####################################################

	private

	# Strong parameters
	def lender_application_params
		params.require(:lender_application).permit(:keyword, :skill, :hours, :summary, :status, :staff_notes)
	end

end