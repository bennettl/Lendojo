class LenderApplicationsController < ApplicationController

	# Include sorting params for sortable headers on index page
	include HeaderFiltersHelper
	
	# Swagger documentation
	swagger_controller :lender_applications, "Lender Application operations"

	# Shows a list of lender applications
	swagger_api :index do
		summary "Show A Lists Of All Lender Applications"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		@lenderApps = LenderApplication.all.order("#{sort_name_param} #{sort_direction_param}").paginate( per_page: 5, page: params[:page] )
		
		# Respond to multiple formats
		respond_to do |format|
		    format.html # index.html.erb
		    format.json { render json: @lenderApps }
		end
	end

	# Shows an individual lender application
	swagger_api :show do
		summary "Show Indivdual Lender Applications"
		param :path, :id, :integer, :required, "ID"
	end
	def show
		@lenderApp = LenderApplication.find(params[:id])
		# Respond to JSON
		respond_to do |format|
		    format.json { render json: @lenderApp }
		end
	end

	# Displays a form for 
	def new
		@lenderApp = LenderApplication.new
	end

	# Creates a new lender application
	swagger_api :create do
		summary "Creates A New Lender Application"
		param :form, 'lender_application[author_id]', :integer, :required, "Author ID"
		param :form, 'lender_application[categories]', :string, :required, "Categories"
		param :form, 'lender_application[skill]', :string, :required, "Skill"
		param :form, 'lender_application[hours]', :integer, :required, "Hours"
		param :form, 'lender_application[summary]', :string, :required, "Summary"
	end
	def create
		@lenderApp = current_user.build_lender_app(lender_application_params)

		# If a new lenderApp is sucessfully save, redirect ot services index path, else re-render new
		if @lenderApp.save
			flash[:success] = "Thanks for the application! We will get back to you shortly."
			# Notify admin that a new application has been submitted
			LenderApplicationsMailer.set_created_mail(@lenderApp).deliver
			
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

	# Update the lender application
	swagger_api :update do
		param :path, 'id', :integer, :required, "Application ID"
		param :form, 'lender_application[categories]', :string, :required, "Categories"
		param :form, 'lender_application[skill]', :string, :required, "Skill"
		param :form, 'lender_application[hours]', :integer, :required, "Hours"
		param :form, 'lender_application[summary]', :string, :required, "Summary"
		param_list :form, 'lender_application[status]', :status, :optional, "Status", LenderApplication.statuses.keys
		param :form, 'lender_application[staff_notes]', :string, :required, "Staff Notes"
	end
	def update
		@lenderApp = LenderApplication.find(params[:id])

		# Change the user's lender status base on the lender application status
		data = (params[:lender_application][:status] == 'approved') ? { lender: true, belt: 'white'} : { lender: false, belt: 'N/A' } 

		# If lenderApp AND lender is sucessfully updated, redirect to index path, else re-render edit
		if @lenderApp.update_attributes(lender_application_params) && @lenderApp.author.update_attributes(data)
			flash[:success] = "Application has been successfully updated!"
			
			# Notify user if status is approved or denied
			if @lenderApp.status == 'approved' || @lenderApp.status == 'denied'
				LenderApplicationsMailer.set_updated_mail(@lenderApp, @lenderApp.author).deliver
			end

			# Respond to multiple formats
			respond_to do |format|
			    format.html { redirect_to lender_applications_path }
			    format.json { render json: @lenderApps }
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

	private

	# Strong parameters
	def lender_application_params
		params.require(:lender_application).permit(:categories, :skill, :hours, :summary, :status, :staff_notes)
	end

end