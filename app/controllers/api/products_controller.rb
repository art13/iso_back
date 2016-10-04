module Api
	class ProductsController < ApplicationController
		def index
			params[:per_page] ||= 100
			params[:page] ||= 1
			
			@products =
			if params[:in_category]
				Product.where(:category_id => params[:in_category].to_i)
			else
				Product.find_each(:batch_size => 500)
			end
			@products = asjson(@products)
			max_count = @products.size
			@products = Kaminari.paginate_array(@products).page(params[:page]).per(params[:per_page])
			@count = @products.size
			render :json => {:per_page => params[:per_page].to_i, :current_page => params[:page].to_i,
							 :max_count => max_count, :count_on_page => @count, :products =>  @products} 
		end

		def show
			product = 
				case params[:id].to_i > 0
				when true
					Product.find_by_id(params[:id])
				when false
					Product.find_by_permalink(params[:id])
				end
			render :json => asjson(product)
		end

		def asjson(product)
			product.as_json(:only => [:id, :category_id, :permalink, :name, :updated_at], :methods => [:photo_url, :product_properties])
		end
	end

end