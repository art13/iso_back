module Api
	class CategoriesController < ApplicationController
		def index
			params[:per_page] ||= 100
			params[:page] ||= 1
			@category = Category
			@category = @category.get_parents if params[:only_head_categories]
			@category = @category.get_children(params[:get_children]) if params[:get_children]
			max_count = @category.all.size


			@categories = @category.page(params[:page]).per(params[:per_page]).as_json(:only => [:id, :parent_id, :name, :permalink])
			@count = @categories.size
			render :json => {:per_page => params[:per_page].to_i, :current_page => params[:page].to_i,
							 :max_count => max_count, :count_on_page => @count, :categories =>  @categories} 
		end

		def show 
			@category = Category.find_by_id(params[:id]).as_json(:only => [:id, :parent_id, :name, :permalink])
			render :json => {:category => @category}
		end
	end	
end