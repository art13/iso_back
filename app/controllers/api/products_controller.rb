module Api
	class ProductsController < ApplicationController
		def index
			params[:per_page] ||= 100
			params[:page] ||= 1
			max_count = Product.all.size
			@products = Product.page(params[:page]).per(params[:per_page])
			@count = @products.size
			render :json => {:per_page => params[:per_page].to_i, :current_page => params[:page].to_i,
							 :max_count => max_count, :count_on_page => @count, :products =>  @products} 
		end
	end

end