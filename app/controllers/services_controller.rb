class ServicesController < ApplicationController
	
	# List all services
	def index
		@services = Service.all.paginate(per_page: 12, page: params[:page])
	end

	# Display individual service
	def show
		@service = Service.find(params[:id])
	end

	# Displays a form to create a new service
	def new
		@service = Service.new
	end

	# Creates the new service
	def create
		@service = Service.new(service_params)
		if @servce.save
			flash[:success] = "Service Successfully Created!"
			redirect_to @service
		else
			render 'new'
		end
	end

	# Displays a form to update an existing service
	def edit
		@service = Service.find(params[:id])
	end

	# Updates an existing service
	def update
		@service = Service.find(params[:id])

		if @service.update_attributes(service_params)
			flash[:success] = "Service Successfully Updated!"
			redirect_to @service
		else
			render 'edit'
		end
	end

	# Reports an existing service
	def report
		@service = Service.find(params[:id]) 
	end
	
	# Destroys the existing service
	def destroy
		Service.destroy(params[:id])
	end

	private

	# Strong parameters
	def service_params
		params.require(:service).permit(:title, :headline, :description, :location, :price, :categories, :tags, :image_one)
	end

end
