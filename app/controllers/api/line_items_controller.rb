module Api
	class LineItemsController < ApplicationController
		def index
			items = Product.where(:id => params[:ids].split(',')) if params[:ids]
			render :json => items.as_json(:only => [:id, :name, :price])
		end

		def show
			item = Product.find_by_id(params[:id])
			render :json => item.as_json(:only => [:id, :name, :price])	
		end
	end
end