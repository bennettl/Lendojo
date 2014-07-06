class ProductsController < ApplicationController
	##################################################### FILTERS #####################################################

	##################################################### RESOURCES #####################################################
	# Requires users to sign in before accessing action
	# before_filter :authenticate_user!

	# Shows an individual product
	swagger_api :show do
		summary "Show indivdual product"
		param :path, :id, :integer, :required, "Product ID"
	end
	def show
		if @product = Product.find_by(id: params[:id])
			# Respond to different formats
			respond_to do |format|
			  format.html # show.html.erb
			  format.json { render json: @product }
			end
		else
			# Respond to different formats
			respond_to do |format|
			  format.html { redirect_to :back }
			  format.json { render json: { message: "Product does not exist" } }
			end
		end
	end
	# Destroy an existing product
	swagger_api :destroy do
		summary "Destroy an existing product"
		param :path, :id, :integer, :required, 'Product ID'
	end
	def destroy
		if @product = Product.find_by(id: params[:id])
			render json: @product.destroy
		else
			render json: { message: "Product Not Found" }
		end
	end

end
