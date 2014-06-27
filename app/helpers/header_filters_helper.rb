module HeaderFiltersHelper
	# Provides controllers with sortable headers with sort_name_param and sort_direction values 

	# Sorting params
	def sort_name_param
		if (params[:sort].nil? || params[:sort][:name].empty?)
			'updated_at' # default
		else
			params[:sort][:name]		
		end
	end

	def sort_direction_param
		if (params[:sort].nil? || params[:sort][:direction].empty?)
			'desc' # default
		else
			params[:sort][:direction]		
		end
	end

end
