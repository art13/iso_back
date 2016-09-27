module Api
	class CategoriesController < ApplicationController
		def index
			@categories = Category.all.as_json(:only => [:id, :parent_id, :name, :permalink])
			render :json => @categories
		end
	end	
end