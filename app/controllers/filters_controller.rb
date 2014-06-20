class FiltersController < ApplicationController

	# Will handle creating AND updating a filter
	def create
		# If filter with title exists, return the object, else create one with .new 
		filter = current_user.filters.find_or_initialize_by(title: params[:title])
		# Save to active record database
		filter.update_attribute('data', filter_params)
		
		respond_to do |format|
			# Return JSON
		    msg = { status: "Success", my_filter: { id: filter.id, data: filter.data, title: filter.title } }
		    format.json  { render :json => msg }
		end
	end

	# Update filter (only use for alerts)
	def update
		filter = Filter.find(params[:id])
		filter.update_attributes(filter_params)

		respond_to do |format|
			# Return JSON
		    msg = { status: "sucess", message: "Success!" }
		    format.json  { render :json => msg }
		end
	end

	# Destroy an existing filter
	# If have time, check to see if user has permission to remove filter
	def destroy
		Filter.find(params[:id]).destroy
	end

	private

	# Strong parameters
	def filter_params
		params.require(:filter_data).permit(:alert, locations: [], prices: [], belts: [], keywords: [])
	end

end
