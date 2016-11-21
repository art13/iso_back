module Api
	class ProductsController < ApplicationController
		def index
			params[:per_page] ||= "100"
			params[:page] ||= "1"
			Product.prod_props = Category.all
			@product_s = Product
			# @product_s = in_category(params[:in_category]).products if params[:in_category]
			@product_s = @product_s.search_by_props(params[:prop_eq]) if params[:prop_eq]
			params[:props_lt].to_a.each do |prop|
				@product_s = @product_s.props_lt(prop[0], prop[1])
			end if params[:props_lt].present?
			params[:props_gt].to_a.each do |prop|
				@product_s = @product_s.props_gt(prop[0], prop[1])
			end if params[:props_gt].present?	
			@product_s = @product_s.price_btw(params[:price_gt], params[:price_lt]) if params[:price_lt] || params[:price_gt]

			#@product_s = @product_s.where(:category_id => params[:in_category].to_i) 
			@products = asjson(@product_s.order("id ASC").page(params[:page]).per(params[:per_page]))
			max_count = @product_s.all.size
			@count = @products.size
			render :json => {:per_page => params[:per_page].to_i, :current_page => params[:page].to_i,
							 :max_count => max_count, :count_on_page => @count, :products =>  @products} 
		end

		def show
			Product.prod_props = Category.all
			product = 
				case params[:id].to_i > 0
				when true
					Product.find_by_id(params[:id])
				when false
					Product.find_by_permalink(params[:id])
				end
			render :json => product.as_json(:only => [:id, :category_id, :permalink, :name, :price, :code, :description, :updated_at], :methods => [:rating, :photo_url, :product_properties, :sample_products, :product_categories, :comments, :more_images]) 
		end

		def asjson(product)
			product.as_json(:only => [:id, :category_id, :permalink, :name, :price, :code, :updated_at], :methods => [:photo_url, :product_properties, :product_categories, :rating])
		end

		def in_category(param)
			case param.to_i > 0		
			when true 
				Category.find_by_id(param)
			when false
				Category.find_by_permalink(param)	
			end
		end
	end

end