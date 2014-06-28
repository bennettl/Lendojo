class ServicesController < ApplicationController
	
	# Swagger documentation
	swagger_controller :services, "Services"

	# List all services
	def index

		@myFilters 		= current_user.filters
		# If there are no search parameters and user has filters, use the first filter to search
		search_params 	= (search_params().empty? && !@myFilters.nil?) ? @myFilters.first : search_params()

		@services = Service.search(search_params).paginate(per_page: 9, page: params[:page])

		# Respond to multiple formats
		respond_to do |format|
		    format.html
		    format.js
		end
	end

	# Display individual service
	def show
		@service = Service.find(params[:id])
		@reviews = @service.lender.reviews_recieved.paginate(per_page: 4, page: params[:review_page])
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
		params.require(:service).permit(:main_img, :title, :headline, :description, :location, :price, :category, :tags, :hidden)
	end

	# Parameters (filter_data) use for searching
	def search_params
		# If there is no filter data, return empty
		if params[:filter_data].nil?
			return ''
		end
		
		# Fixes error when any of the array is nil by setting default to an empty array
		params[:filter_data][:locations] ||= []
		params[:filter_data][:prices] ||= []
		params[:filter_data][:belts] ||= []
		params[:filter_data][:keywords] ||= []

		params.require(:filter_data).permit(locations: [], prices: [], belts: [], keywords: [])
	end

end
