module Api
	class ProductsController < ApplicationController
		def index
			params[:per_page] ||= 100
			params[:page] ||= 1
			
			@products =
			if params[:in_category]
				Product.where(:category_id => params[:in_category].to_i)
			else
				Product.all
			end
			@products = @products.as_json(:only => [:id, :category_id, :name, :properties, :updated_at], :methods => :photo_url)
			max_count = @products.size
			@products = Kaminari.paginate_array(@products).page(params[:page]).per(params[:per_page])
			@count = @products.size
			render :json => {:per_page => params[:per_page].to_i, :current_page => params[:page].to_i,
							 :max_count => max_count, :count_on_page => @count, :products =>  @products} 
		end
	end

end