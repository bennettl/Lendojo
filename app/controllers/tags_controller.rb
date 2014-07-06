class TagsController < ApplicationController
	
	##################################################### SWAGGER #####################################################

	swagger_controller :tags, "Tag Operations"

	##################################################### RESOURCES #####################################################

	# Show a list of tags
	swagger_api :index do
		summary "Show a list of tags"
		param :query, 'tag[category]', :string, :optional, "Category"		
		param :query, 'tag[name]', :string, :optional, "Name"	
	end
	def index
		@tags = Tag.search(search_params)
			
		respond_to do |format|
			format.js # index.js.erb
			format.json { render json: @tags }
		end
	end

	# Show an individual tag
	swagger_api :show do 
		summary "Show an individual tag"
		param :path, :id, :integer, :required, "Tag ID"
	end
	def show
		if @tag = Tag.find_by(id: params[:id])
			render json: @tag
		else
			render json: { message: "Tag does not exist" }
		end
	end

	# Create a new tag
	swagger_api :create do
		summary "Create a new tag"
		param :form, 'tag[category]', :string, :required, "Category"		
		param :form, 'tag[name]', :string, :required, "Name"
	end
	def create
		@tag = Tag.new(tag_params)
		if @tag.save
			render json: @tag
		else
			render json: { message: "Tag Was Not Successfully Created", error: @tag.errors.full_messages }
		end
	end

	# Update an existing tag
	swagger_api :update do
		summary "Update an existing tag"
		param :path, 'id', :integer, :required, "Tag ID"
		param :form, 'tag[category]', :string, :optional, "Category"		
		param :form, 'tag[name]', :string, :optional, "Name"
		param :form, 'tag[count]', :string, :optional, "Count"
	end
	def update
		@tag = Tag.find_by(id: params[:id])
		if @tag.update_attributes(tag_params)
			render json: @tag
		else
			render json: { message: "Tag Was Not Successfully Updated", error: @tag.errors.full_messages }
		end
	end

	# Destroy an existing tag
	swagger_api :destroy do
		summary "Destroy an existing tag"
		param :path, :id, :integer, :required, "Tag ID"
	end
	def destroy
		if	@tag = Tag.find_by(id: params[:id])
			render json: @tag.destroy
		else
			render json: { message: "Tag Not Found"}
		end
	end

	##################################################### PRIVATE #####################################################

	private 

	# Strong params use for searching
	def search_params
		# # If there is tag information to search for, return empty
		# if params[:tag].nil?
		# 	return ''
		# end
		params.require(:tag).permit(:category, :name)
	end

	# Strong params use for creation or update
	def tag_params
		params.require(:tag).permit(:category, :name, :count)
	end

end
