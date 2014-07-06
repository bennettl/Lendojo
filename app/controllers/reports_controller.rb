class ReportsController < ApplicationController
	
	##################################################### FILTERS #####################################################
	
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!
	
	# Include sorting params for sortable headers on index page
	include HeaderFiltersHelper

	##################################################### SWAGGER #####################################################

	swagger_controller :reports, "Report operations"

	################################################ RESOURCES #######################################################

	# Show a list of reports
	swagger_api :index do
		summary "Show a list of reports"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		# If there are no speicfic reportables, then show all
		@reports = Report.all.search(search_params)
		@reports = @reports.order("#{sort_name_param} #{sort_direction_param}").paginate( per_page: 5, page: params[:page] )
		# Respond to multiple formats
		respond_to do |format|
			format.html # index.html.erb
		    format.js # index.js.erb
		    format.json { render json: @reports }
		end
	end

	# Show an individual report
	swagger_api :show do
		summary "Show an individual report"
		param :path, :id, :integer, :required, "Report ID"
	end
	def show
		if @report = Report.find_by(id: params[:id])
			# Respond to different formats
			respond_to do |format|
			  format.html # show.html.erb
			  format.json { render json: @report }
			end
		else
			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to :back }
			  format.json { render json: { message: "Report does not exist" } }
			end
		end
	end

	# Displays a form to create a new report
	def new
		 # the (user/service/product) the object
		@reportable = find_reportable

		case @reportable.class.name
			when 'User'
				@reportable_path = report_user_path(@reportable, author_id: current_user.id)
			when 'Service'
				@reportable_path = report_service_path(@reportable, author_id: current_user.id)
			when 'Product'
				@reportable_path = report_product_path(@reportable, author_id: current_user.id)
			when 'Review'
				@reportable_path = report_review_path(@reportable, author_id: current_user.id)
		end

	end
		
	# Creates a new report
	swagger_api :create do
		summary "Create a report"
		param :path, 		:id, 							:integer,	:required, 'Reportable ID'
		param :query, 		'author_id', 					:integer, 	:required, 'Author ID'
		param_list :form, 	'report[reportable_type]', 		:string, 	:required, 'Reportable Type', ['User', 'Service', 'Review']
		param_list :form, 	'report[reason]', 				:integer, 	:required, "Reason", Report.reasons.keys
		param :form, 		'report[summary]', 				:string, 	:required, "Summary"
	end
	def create
		# the (user/service/product) the object
		user 		= User.find(params[:author_id])

		# the (user/service/product) the object
		@reportable = params[:report][:reportable_type].classify.constantize.find(params[:id])

		# If report creation was successful
		if @report 	= user.report!(@reportable, report_params)
			flash[:success] = "Thank you for submitting the report! We will review it shortly."
			# Respond to multiple formats
			respond_to do |format|
				format.html { redirect_to @reportable }
			    format.json { render json: @report }
			end

			
		else
			flash[:error].now = @report.errors.full_messages
			# Respond to multiple formats
			respond_to do |format|
				format.html { render 'edit' }
			    format.json { render json: { message: 'Service Report Unsuccessful', error: flash[:error] } }
			end
		end
	end

	# Displays the form to edit an individual report
	def edit
		@report = Report.find(params[:id])
		# The (user/service/product) object
		@reportable = @report.reportable_type.constantize.find(@report.reportable_id)
	end

	
	# Updates an existing report
	swagger_api :update do
		summary "Update an existing report"
		notes "current_user is giving the rating"
		param 		:path, 'id', 					:integer, 	:required, "Report ID"
		param 		:form, 'report[staff_notes]', 	:string, 	:optional, "Staff Notes"
		param_list 	:form, 'report[status]', 		:string, 	:optional, "Status", Report.statuses.keys
		param_list 	:form, 'report[action]', 		:string, 	:optional, "Action", Report.actions.keys
	end
	def update
		@report = Report.find(params[:id])
		# The (user/service/product) object
		@reportable = @report.reportable_type.constantize.find(@report.reportable_id)

		# If update was successful, redirect user back to reports path, otherwise re-render edit 
		if @report.update_attributes(report_params)
			
			# Change user status and send email base on the action selected by staff
			process_staff_action

			flash[:success] = "Sucessfully updated report!"
			
			# Respond to multiple formats
			respond_to do |format|
				format.html { redirect_to reports_path }
			    format.json { render json: @report }
			end
			
		else
			flash[:error].now = @report.errors.full_messages
			# Respond to multiple formats
			respond_to do |format|
				format.html { render 'edit' }
			    format.json { render json: { message: 'Report Update Unsuccessful', error: flash[:error].now } }
			end
		end
	end

	# Destroy an existing service
	swagger_api :destroy do
		summary "Destroy an existing report"
		param :path, :id, :integer, :required, 'Report ID'
	end
	def destroy
		if @report = Report.find_by(id: params[:id])
			render json: @report.destroy
		else
			render json: { message: "Report Not Found" }
		end
	end

	################################################ HELPER FUNCTIONS #######################################################
	
	# Base on the action chosen by the staff ('n/a', 'warn', 'suspend', 'ban'), change user status and notify user of action
	def process_staff_action

		# Get the user status base on the report action
		case params[:report][:action]
			when 'warn'
				status = 'warned'
			when 'suspend'
				status = 'suspended'
			when 'ban'
				status = 'banned'
			else
				status = ''
		end

		# Only update status and notify user if the status is not empty
		unless status.empty?
			# Get the user base on the type of reportable object
			case @report.reportable_type
				when 'User'
					user = @reportable
				when 'Service'
					user = @reportable.lender
				when 'Product'
					user = @reportable.lender
				when 'Review'
					user = @reportable.author
			end
			user.update_attribute('status', status)
			UserStatusMailer.set_mail(user).deliver # send mail
		end

	end


	# Returns object. Loop through the parameters passed to the action to look one called <parent_resource>_id which will enable us to know which of the commentable models we’re dealing with. http://railscasts.com/episodes/154-polymorphic-association?view=asciicast
	def find_reportable
		# http://localhost:3000/services/18/report?author_id=1  -> services -> service -> Service
		request.original_url.split("/")[3].singularize.capitalize.classify.constantize.find(params[:id])		
	end

	private

	# Strong parameters
	def report_params
		params.require(:report).permit(:reason, :summary, :action, :staff_notes, :status)
	end

	
	# Serach params (filter_data)
	def search_params
		# If there is no filter data, return empty
		if params[:filter_data].nil?
			return ''
		end

		params.require(:filter_data).permit(statuses: [], reportable_types: [])
	end

end
