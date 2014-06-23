class LenderApplicationsController < ApplicationController

	# Displays a list of lender applications
	def index
		@lenderApps = LenderApplication.all.order("updated_at DESC")
	end

	# Displays a form for 
	def new
		@lenderApp = LenderApplication.new
	end

	# Creates a new lender application
	def create
		@lenderApp = current_user.lender_app.new(lender_application_params)

		# If a new lenderApp is sucessfully save, redirect ot services index path, else re-render new
		if @lenderApp.save
			flash[:success] = "Thanks for the application! We will get back to you shortly."
			redirect_to services_path
		else
			render 'new'
		end
	end

	# Displays a form to update lender application
	def edit
		@lenderApp = LenderApplication.find(params[:id])
	end

	# Update the lender application
	def update
		@lenderApp = LenderApplication.find(params[:id])

		# If lenderApp is sucessfully updated, redirect to index path, else re-render edit
		if @lenderApp.update_attributes(lender_application_params)
			flash[:success] = "Application has been successfully update"

			# Change the user's lender status base on the lender application status
			if params[:lender_application][:status] == 'approved'
				data = { lender: true, belt: 'white'}
			else
				data = { lender: false }
			end

			@lenderApp.author.update_attributes(data)

			redirect_to lender_applications_path
		else
			render 'edit'
		end

	end

	private

	# Strong parameters
	def lender_application_params
		params.require(:lender_application).permit(:categories, :skill, :hours, :summary, :status, :staff_notes)
	end

end
