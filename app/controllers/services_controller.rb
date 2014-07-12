class ServicesController < ApplicationController
	##################################################### FILTERS #####################################################
	
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!

	# Check to see if user signed up is complete before accessing actions of controller
	before_filter :ensure_signup_complete
	
	##################################################### SWAGGER #####################################################

	swagger_controller :services, "Service operations"

	##################################################### RESOURCES #####################################################

	# Shows all services
	swagger_api :index do
		summary "Shows all services"
		param :query, :page, :integer, :optional, "Page Number"
	end
	def index
		@myFilters 		= current_user.filters
		# If there are no search parameters and user has filters, use the first filter to search
		search_params 	= (search_params().empty? && !@myFilters.nil?) ? @myFilters.first : search_params()
		@services 		= Service.search(search_params).paginate(per_page: 9, page: params[:page])
		# Get top 5locations and keywords tag
		@location_tags 	= Tag.where("category = 'location'").order("count DESC").limit(5)
		@keyword_tags 	= Tag.where("category = 'keyword'").order('count DESC').limit(5)

		# Respond to multiple formats
		respond_to do |format|
		    format.html # index.html.erb
		    format.js # index.js.erb
		    format.json { render json: @services }
		end
	end

	# Shows an individual service
	swagger_api :show do
		summary "Shows an individual service"
		param :path, :id, :integer, :required, "Service ID"
	end
	def show
		if @service = Service.find_by(id: params[:id])
			@reviews = @service.lender.reviews_recieved.paginate(per_page: 4, page: params[:review_page])
			# Respond to different formats
			respond_to do |format|
			  format.html # show.html.erb
			  format.js # show.js.erb
			  format.json { render json: @service }
			end
		else
			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to :back }
			  format.json { render json: { message: "Service does not exist" } }
			end
		end
	end

	# Displays a form to create a new service
	def new
		@service = Service.new
	end

	# Creates a new service
	swagger_api :create do
		summary "Creates a new service"
		param :query, 'id', :integer, :required, 'Lender ID'
		param :form, 'service[main_img]', :string, :required, 'Main Image'
		param :form, 'service[title]', :string, :required, 'Title'
		param :form, 'service[headline]', :string, :required, 'Headline'
		param :form, 'service[description]', :string, :required, 'Description'
		param :form, 'service[location]', :string, :required, 'Location'
		param :form, 'service[address]', :string, :required, 'Address'
		param :form, 'service[city]', :string, :required, 'City'
		param :form, 'service[state]', :string, :required, 'State'
		param :form, 'service[zip]', :string, :required, 'Zip'
		param :form, 'service[price]', :integer, :required, 'Price'
		param :form, 'service[category]', :string, :optional, 'Category'
		param :form, 'service[tags]', :string, :optional, 'Tags'
		param :form, 'service[hidden]', :boolean, :optional, 'Hidden'
	end
	def create
		@service = Service.new(service_params)
		if @servce.save
			flash[:success] = "Service Successfully Created!"
			# Respond to multiple formats
			respond_to do |format|
			    format.html { redirect_to @service }
			    format.json { render json: @service }
			end
		else
			flash[:error] = @service.errors.full_messages
			# Respond to multiple formats
			respond_to do |format|
			    format.html { render 'new' }
			    format.json { render json: { message: "Service Was Not Successfully Created", error: flash[:error] } }
			end
			
		end
	end

	# Displays a form to update an existing service
	def edit
		@service = Service.find(params[:id])
	end

	# Update an existing service
	swagger_api :update do
		summary "Updates a existing service"
		param :path, 'id', :integer, :required, 'Service ID'
		param :form, 'service[main_img]', :string, :optoinal, 'Main Image'
		param :form, 'service[title]', :string, :optoinal, 'Title'
		param :form, 'service[headline]', :string, :optoinal, 'Headline'
		param :form, 'service[description]', :string, :optoinal, 'Description'
		param :form, 'service[location]', :string, :optoinal, 'Location'
		param :form, 'service[address]', :string, :optoinal, 'Address'
		param :form, 'service[city]', :string, :optoinal, 'City'
		param :form, 'service[state]', :string, :optoinal, 'State'
		param :form, 'service[zip]', :string, :optoinal, 'Zip'
		param :form, 'service[price]', :integer, :optoinal, 'Price'
		param :form, 'service[category]', :string, :optional, 'Category'
		param :form, 'service[tags]', :string, :optional, 'Tags'
		param :form, 'service[hidden]', :boolean, :optional, 'Hidden'
	end
	def update
		@service = Service.find_by(id: params[:id])

		if @service.update_attributes(service_params)
			flash[:success] = "Service Successfully Updated!"
			# Respond to multiple formats
			respond_to do |format|
			    format.html { redirect_to @service }
			    format.json { render json: @service }
			end
		else
			flash[:error] = @service.errors.full_messages
			# Respond to multiple formats
			respond_to do |format|
			    format.html { render 'edit' }
			    format.json { render json: { message: "Service Was Not Successfully Updated", error: flash[:error] } }
			end
		end
	end
	
	# Destroy an existing service
	swagger_api :destroy do
		summary "Destroy an existing service"
		param :path, :id, :integer, :required, 'Service ID'
	end
	def destroy
		if @service = Service.find_by(id: params[:id])
			render json: @service.destroy
		else
			render json: { message: "Service Not Found" }
		end
	end


	##################################################### CHECK/PIN #####################################################

	# Check a service
	swagger_api :check do
		summary "Check a service"
		param :path, :id, :integer, :required, "Service ID"
		param :query, :user_id, :integer, :required, "User ID"
	end
	def check
		user 		= User.find(params[:user_id])	
		@service 	= Service.find(params[:id])

		# Create the appropriate JSON
		if @user_service = user.check!(@service)
			@json = @user_service
		else
			@json = { message: "Check Service Unsuccessful", error: @user_service.errors.full_messages }
		end

		# Respond to different formats
		respond_to do |format|
			format.js # check.js.erb
			format.json { render json: @json }
		end

	end

	# Uncheck a service
	swagger_api :uncheck do
		summary "Check a service"
		param :path, :id, :integer, :required, "Service ID"
		param :query, :user_id, :integer, :required, "User ID"
	end
	def uncheck
		user 		= User.find(params[:user_id])	
		@service 	= Service.find(params[:id])

		# Create the appropriate JSON
		if @user_service = user.uncheck!(@service)
			@json = @user_service
		else
			@json = { message: "Uncheck Service Unsuccessful", error: @user_service.errors.full_messages }
		end

		# Respond to different formats
		respond_to do |format|
			format.js # check.js.erb
			format.json { render json: @json }
		end
	end

	# Pin a service
	swagger_api :pin do
		summary "Pin a service"
		param :path, :id, :integer, :required, "Service ID"
		param :query, :user_id, :integer, :required, "User ID"
	end
	def pin
		user 		= User.find(params[:user_id])
		@service 	= Service.find(params[:id])
		
		# Create the appropriate JSON
		if @user_service = user.pin!(@service)
			@json 	= @user_service
		else
			@json 	= { message: "Pin Service Unsuccessful", error: @user_service.errors.full_messages }
		end

		# Respond to different formats
		respond_to do |format|
			format.js # pin.js.erb
			format.json { render json: @json }
		end

	end

	# Unpin a service
	swagger_api :unpin do
		summary "Unpin a service"
		param :path, :id, :integer, :required, "Service ID"
		param :query, :user_id, :integer, :required, "User ID"
	end
	def unpin
		user 		= User.find(params[:user_id])
		@service 	= Service.find(params[:id])
		
		# Create the appropriate JSON
		if @user_service = user.unpin!(@service)
			@json 	= @user_service
		else
			@json 	= { message: "Unpin Service Unsuccessful", error: @user_service.errors.full_messages }
		end

		# Respond to different formats
		respond_to do |format|
			format.js # unpin.js.erb
			format.json { render json: @json }
		end

	end

	##################################################### PRIVATE #####################################################

	private

	# Strong parameters
	def service_params
		params.require(:service).permit(:main_img, :title, :headline, :description, :location, :address, :city, :state, :zip, :price, :category, :tags, :hidden)
	end

	# Strong parameters
	def report_params
		params.require(:report).permit(:reason, :summary, :action, :staff_notes, :status)
	end

	# Parameters (tag_data) use for searching
	def search_params
		# If there is no filter data, return empty
		if params[:tag_data].nil?
			return ''
		end
		
		# Fixes error when any of the array is nil by setting default to an empty array
		params[:tag_data][:location] ||= []
		params[:tag_data][:price] ||= []
		params[:tag_data][:belt] ||= []
		params[:tag_data][:keyword] ||= []

		params.require(:tag_data).permit(location: [], price: [], belt: [], keyword: [])
	end

end
