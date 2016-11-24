module Api
	class ProductsController < ApplicationController
		def index
			params[:per_page] ||= "100"
			params[:page] ||= "1"
			Product.prod_props = Category.where(:show_on_front => true)
			@product_s = Product.joins(:category).where(:categories => {:show_on_front => true})
			@product_s = in_category(Product.prod_props, check_params(Category, params[:in_category])) if params[:in_category]
			@product_s = @product_s.search_by_props(params[:prop_eq]) if params[:prop_eq]
			params[:props_lt].to_a.each do |prop|
				@product_s = @product_s.props_lt(prop[0], prop[1])
			end if params[:props_lt].present?
			params[:props_gt].to_a.each do |prop|
				@product_s = @product_s.props_gt(prop[0], prop[1])
			end if params[:props_gt].present?	
			@product_s = @product_s.price_btw(params[:price_gt], params[:price_lt]) if params[:price_lt] || params[:price_gt]
			@products = asjson(@product_s.order("id ASC").page(params[:page]).per(params[:per_page]))
			max_count = @product_s.all.size
			@count = @products.size
			render :json => {:per_page => params[:per_page].to_i, :current_page => params[:page].to_i,
							 :max_count => max_count, :count_on_page => @count, :products =>  @products} 
		end

		def show
			Product.prod_props = Category.where(:show_on_front => true)
			product = check_params(Product, params[:id])
			render :json => product.as_json(:only => [ :category_id, :permalink, :name, :price, :code, :description, :updated_at], :methods => [:rating, :photo_url, :product_properties, :sample_products, :product_categories, :comments, :more_images]) 
		end

		def asjson(product)
			product.as_json(:only => [:id, :category_id, :permalink, :name, :price, :code, :updated_at], :methods => [:photo_url, :product_properties, :product_categories, :rating])
		end

		def check_params(obj, param)
			case param.to_i > 0		
			when true 
				obj.find_by_id(param)
			when false
				obj.find_by_permalink(param)	
			end
		end

		def in_category(categories, category)
			results_ids = []
			@second_level = []
			parent = categories.to_a.detect{|w| w.id == category.id}
			@first_level = categories.to_a.select{|w| w.parent_id == parent.id}
			@first_level.each do |first_level_parent|
				@second_level += categories.to_a.select{|w| w.parent_id == first_level_parent.id}
			end 
			results_ids = @first_level.pluck(:id) + @second_level.pluck(:id) << parent.id  
			return Product.where(:category_id => results_ids.uniq)
		end
	end

end