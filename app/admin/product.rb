ActiveAdmin.register Product do
	permit_params :name, :price, :code, :description, :permalink, :category_id, :admin_user_id
	before_filter :only => [:show, :edit, :update, :destroy] do
        @product = Product.find_by_permalink(params[:id])
    end
    after_build do |product|
		product.admin_user = current_admin_user
	end 	
	filter :name
	filter :code
	filter :price
	filter :created_at
	filter :updated_at
	index do 
		selectable_column
		column :id
		column :name do |p|
			link_to p.name, admin_product_path(p)
		end
		column "image" do |product|
		  image_tag product.photo.url, class: 'pic'
		end
		column :price
		column :created_at
		column :updated_at
		actions
	end
	form do |f|
		f.inputs t("products") do
			f.input :name
			f.input :permalink
			f.input :price
			f.input :code
			f.input :category, :as => :select
			f.input :photo, :as => :file
			f.input :description
			f.input :admin_user_id, :input_html => { :value => current_admin_user.id }, as: :hidden
		end
		f.actions
	end 
	show  :download_links => false do |product|  
		attributes_table do
			row :name
			row :code
			row :permalink
			row :description
			row "image" do |p|
				image_tag p.photo.url, class: 'row_pic'
			end
			row :category
			render :partial => "product_properties", :locals => {:properties => product.properties}
			row :updated_at
			row :admin_user

		end
	end
end