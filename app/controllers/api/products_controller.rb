module Api
	class ProductsController < ApplicationController
		def index
			params[:per_page] ||= 100
			params[:page] ||= 1
			
			@products =
			if params[:in_category]
				asjson_filter(Product.where(:category_id => params[:in_category].to_i))
			else
				asjson( params[:page].to_i > 1 ? Product.order("id ASC").where("id > ?", params[:per_page].to_i*params[:page].to_i).limit(params[:per_page].to_i) : Product.first(params[:per_page].to_i))
				#asjson(Product.find_each(:batch_size => 1000))
			end
			max_count = Product.all.size
			#@products = Kaminari.paginate_array(@products).page(params[:page]).per(params[:per_page])
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
			render :json => product.as_json(:only => [:id, :category_id, :permalink, :name, :price, :code, :description, :updated_at], :methods => [:photo_url, :product_properties, :sample_products, :comments, :more_images]) 
		end

		def asjson(product)
			product.as_json(:only => [:id, :category_id, :permalink, :name, :price, :code, :updated_at], :methods => [:photo_url, :product_properties])
		end

		def asjson_filter(product)
			product.as_json(:only => [:id, :name, :permalink, :name, :price, :code, :updated_at], :methods => [:photo_url, :product_categories, :rating])
		end

	end

end