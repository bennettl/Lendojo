class ReportsController < ApplicationController
		
	# List all reports under reportable type: user, service, product
	def index
		# the (user/service/product) object
		@reportable = find_reportable

		# If there are no speicfic reportables, then show all
		@reports = (@reportable.nil?) ? Report.all : @reportable.reports_recieved
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

		# If update was successful, redirect user back to reports path, otherwise re-render edit 
		if @report.update_attributes(report_params)
			flash[:success] = "Sucessfully updated report!"
			redirect_to reports_path
		else
			flash[:error].now = "There's a problem updating the report"
			render 'edit'
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
		params.require(:report).permit(:author_id, :reason, :summary, :staff_notes, :status)
	end
end
