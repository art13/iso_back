module Api
	class OrdersController < ApplicationController
		before_filter :order_params
		def create
			#{:order => {:total, :email, :phone, :address, :name, :last_name, :code},:line_items_attributes => [{:product_id, :price, :count}]}
			logger.debug params[:order][:toral]
			logger.debug params["order"]["toral"]
			begin
				@order = Order.create(params["order"])
				if @order
					render :json => {:status => :ok, :order_code => @order.code}
				else
					render :json => {:errors => Order.errors.messages}
				end
			rescue => e
			 	render :json => {:error => e}
			end
			params.require(:order).permit!
		end
 
		def show
			@order = Order.find_by_code(params[:id])
			render :json => @order.as_json(:only =>[:code, :email, :address, :name, :last_name, :phone, :total], :methods => [:line_items])
		end
		private

  		def order_params
  			params.permit!
  		end
	end
end