class FiltersController < ApplicationController

	# Create a new filter
	def create
		current_user.filters.create!(filter_params)
	end

	# Update an existing filter
	def update
		@filter = Filter.find(params[:id])
		@filter.update_attributes(filter_params)
	end

	# Destroy an existing filter
	def destroy
		Filter.find(params[:id]).destroy
	end

	private

	# Strong parameters
	def filter_params
		params.require(:filter)
	end

end
