module Api
	class ProductsController < ApiController
		def index
			params[:per_page] ||= "100"
			params[:page] ||= "1"
			@product_s = Product
			@product_s = @product_s.search_by_props(params[:prop_eq]) if params[:prop_eq]
			params[:props_lt].to_a.each do |prop|
				@product_s = @product_s.props_lt(prop[0], prop[1])
			end if params[:props_lt].present?
			params[:props_gt].to_a.each do |prop|
				@product_s = @product_s.props_gt(prop[0], prop[1])
			end if params[:props_gt].present?
			@products = 
			if params[:in_category]
				pr_s = asjson_filter(@product_s.where(:category_id => params[:in_category].to_i))
				Kaminari.paginate_array(pr_s).page(params[:page]).per(params[:per_page])
			else
				asjson( params[:page].to_i > 1 ? @product_s.order("id ASC").where("id > ?", params[:per_page].to_i*params[:page].to_i).limit(params[:per_page].to_i) : @product_s.first(params[:per_page].to_i))
			end
			max_count = @product_s.all.size
			# products = Kaminari.paginate_array(@products).page(params[:page]).per(params[:per_page])
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
			render :json => product.as_json(:only => [:id, :category_id, :permalink, :name, :price, :code, :description, :updated_at], :methods => [:rating, :photo_url, :product_properties, :sample_products, :comments, :more_images]) 
		end

		def asjson(product)
			product.as_json(:only => [:id, :category_id, :permalink, :name, :price, :code, :updated_at], :methods => [:photo_url, :product_properties, :rating])
		end

		def asjson_filter(product)
			product.as_json(:only => [:id, :name, :permalink, :name, :price, :code, :updated_at], :methods => [:photo_url, :product_categories, :rating])
		end

	end

end