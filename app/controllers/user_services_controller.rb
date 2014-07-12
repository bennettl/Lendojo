class UserServicesController < ApplicationController
	
	# # Make sure user is signed in before creating/destroying relationships
	# before_action :authenticate_user! 

	# # Checks service for current_user and replaces "check" with "_uncheck" partial via create.js.erb
	# def create_check
	# 	# Check the service for user, check!(service) returns the created @user_service object
	# 	# @user_service is needed for rendering _uncheck partial in create_check.js.erb
	# 	service_id = params[:user_service][:service_id]
	# 	@service = Service.find(service_id)
	# 	@user_service = current_user.check!(@service)

	# 	# AJAX. Rail automatically calls a JavaScript Embedded Ruby (.js.erb) file with the same name as the action
	# 	respond_to do |format|
	# 	  format.html { redirect_to @service }
	# 	  format.js # execute create_check.js.erb
	# 	end
	# end

	# # Update the user_service attributes (done via AJAX/asynchronously)
	# def update
	# 	@user_service = UserService.find(params[:id])

	# 	# Continue if update-attribute is sucessful and relationship type is 'check'		
	# 	if @user_service.update_attributes(check_params) && @user_service.relationship_type == 'check'
	# 		# Notify lender that a new application has been submitted
	# 		UserServicesMailer.check_updated(@user_service).deliver
	# 		# If the user service is finished, charge the lendee
	# 		if params[:user_service][:status] == "complete"
	# 			@user_service.charge!
	# 		end
	# 	end
	# end

	# # Unchecks service for current_user and places "_uncheck" with "_check" partial via destroy.js.erb
	# def destroy_check
	# 	# Uncheck the service for user
	# 	@service = UserService.find(params[:id]).service
	# 	current_user.uncheck!(@service)

	# 	# @service will be used for rendering _uncheck partial in destroy_check.js.erb

	# 	# AJAX. Rail automatically calls a JavaScript Embedded Ruby (.js.erb) file with the same name as the action
	# 	respond_to do |format|
	# 	  format.html { redirect_to @service }
	# 	  format.js # execute destroy_check.js.erb
	# 	end
	# end

	# # Checks service for current_user and replaces "check" with "_uncheck" partial via create.js.erb
	# def create_pin
	# 	# Check the service for user, check!(service) returns the created @user_service object
	# 	# @user_service is needed for rendering _uncheck partial in create_pin.js.erb
	# 	service_id = params[:user_service][:service_id]
	# 	@service = Service.find(service_id)
	# 	@user_service = current_user.pin!(@service)

	# 	# AJAX. Rail automatically calls a JavaScript Embedded Ruby (.js.erb) file with the same name as the action
	# 	respond_to do |format|
	# 	  format.html { redirect_to @service }
	# 	  format.js # execute create_pin.js.erb
	# 	end
	# end

	# # Unchecks service for current_user and places "_uncheck" with "_check" partial via destroy.js.erb
	# def destroy_pin
	# 	# Uncheck the service for user
	# 	@service = UserService.find(params[:id]).service
	# 	current_user.unpin!(@service)

	# 	# @service will be used for rendering _uncheck partial in destroy_pin.js.erb

	# 	# AJAX. Rail automatically calls a JavaScript Embedded Ruby (.js.erb) file with the same name as the action
	# 	respond_to do |format|
	# 	  format.html { redirect_to @service }
	# 	  format.js # execute destroy_pin.js.erb
	# 	end
	# end

	# private

	# # Strong parameters for check

	# def check_params
	# 	params.require(:user_service).permit(:date, :address, :city, :state, :zip, :status)
	# end

end
