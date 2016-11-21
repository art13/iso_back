module Api
	class CategoriesController < ApplicationController
		before_action :check_categories
		def index
			params[:per_page] ||= 100
			params[:page] ||= 1
			@category = Category
			@category = @category.get_parents if params[:only_head_categories]
			@category = @category.get_children(params[:get_children]) if params[:get_children]
			max_count = @category.all.size
			@categories = @category.page(params[:page]).per(params[:per_page]).as_json(:only => [:id, :parent_id, :name, :permalink, :position], :methods => :is_final_category)
			@count = @categories.size
			render :json => {:per_page => params[:per_page].to_i, :current_page => params[:page].to_i,
							 :max_count => max_count, :count_on_page => @count, :categories =>  @categories} 
		end

		def show 
			
			@category =  
				case params[:id].to_i > 0
				when true
					Category.find_by_id(params[:id])
				when false
					Category.find_by_permalink(params[:id])
				end
			render :json => @category.as_json(:only => [:id, :parent_id, :name, :permalink, :position], :methods => [:is_final_category, :product_categories])
		end

		def check_categories
			Category.prod_props = Category.all
		end
	end	
end