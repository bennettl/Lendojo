class LenderApplicationsController < ApplicationController

	# Displays a list of lender applications
	def index
		@lenderApps = LenderApplication.all.order("updated_at DESC").paginate( per_page: 5, page: params[:page] )
	end

	# Displays a form for 
	def new
		@lenderApp = LenderApplication.new
	end

	# Creates a new lender application
	def create
		@lenderApp = current_user.build_lender_app(lender_application_params)

		# If a new lenderApp is sucessfully save, redirect ot services index path, else re-render new
		if @lenderApp.save
			flash[:success] = "Thanks for the application! We will get back to you shortly."
			# Notify admin that a new application has been submitted
			LenderApplicationsMailer.set_created_mail(@lenderApp).deliver
			redirect_to services_path
		else
			flash[:error] = @lenderApp.errors.full_messages
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

		# Change the user's lender status base on the lender application status
		data = (params[:lender_application][:status] == 'approved') ? { lender: true, belt: 'white'} : { lender: false, belt: 'N/A' } 

		# If lenderApp AND lender is sucessfully updated, redirect to index path, else re-render edit
		if @lenderApp.update_attributes(lender_application_params) && @lenderApp.author.update_attributes(data)
			flash[:success] = "Application has been successfully updated!"
			
			# Notify user if status is approved or denied
			if @lenderApp.status == 'approved' || @lenderApp.status == 'denied'
				LenderApplicationsMailer.set_updated_mail(@lenderApp, @lenderApp.author).deliver
			end

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
