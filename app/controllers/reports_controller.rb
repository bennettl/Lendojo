class ReportsController < ApplicationController
		
	# Include sorting params
	include HeaderFiltersHelper
	
	# List all reports under reportable type: user, service, product
	def index
		# the (user/service/product) object
		@reportable = find_reportable

		# If there are no speicfic reportables, then show all
		@reports = (@reportable.nil?) ? Report.all : @reportable.reports_recieved
		@reports = @reports.search(search_params)
		@reports = @reports.order("#{sort_name_param} #{sort_direction_param}").paginate( per_page: 5, page: params[:page] )
	end

	# Displays a form to create a new report
	def new
		 # the (user/service/product) the object
		@reportable = find_reportable
	end

	# Creates a new report
	def create
		# the (user/service/product) the object
		@reportable = find_reportable

		if @reportable.reports_recieved.create!(report_params)
			flash[:success] = "Thank you for submitting the report! We will review it shortly."
			redirect_to @reportable
		else
			flash[:error].now = "There's an error processing your report"
			render 'edit'
		end
	end

	# Displays the form to edit an individual report
	def edit
		@report = Report.find(params[:id])
		# The (user/service/product) object
		@reportable = @report.reportable_type.constantize.find(@report.reportable_id)
	end

	
	# Updates an existing report
	def update
		@report = Report.find(params[:id])
		# The (user/service/product) object
		@reportable = @report.reportable_type.constantize.find(@report.reportable_id)

		# If update was successful, redirect user back to reports path, otherwise re-render edit 
		if @report.update_attributes(report_params)
			
			# Change user status and send email base on the action selected by staff
			process_staff_action

			flash[:success] = "Sucessfully updated report!"

			redirect_to reports_path
		else
			flash[:error].now = "There's a problem updating the report"
			render 'edit'
		end
	end


	############################## HELPER FUNCTION ##############################
	
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
		params.each do |name, value|
			if name =~ /(.+)_id$/
			  return $1.classify.constantize.find(value)
			end
		end
		nil
	end

	private

	# Strong parameters
	def report_params
		params.require(:report).permit(:author_id, :reason, :summary, :action, :staff_notes, :status)
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
