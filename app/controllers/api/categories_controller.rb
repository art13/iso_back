module Api
	class CategoriesController < ApplicationController
		def index
			params[:per_page] ||= 100
			params[:page] ||= 1
			max_count = Category.all.size
			@categories = Category.page(params[:page]).per(params[:per_page]).as_json(:only => [:id, :parent_id, :name, :permalink])
			@count = @categories.size
			render :json => {:per_page => params[:per_page].to_i, :current_page => params[:page].to_i,
							 :max_count => max_count, :count_on_page => @count, :categories =>  @categories} 
		end
	end	
end