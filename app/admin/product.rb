ActiveAdmin.register Product do
	before_filter :only => [:show, :edit, :update, :destroy] do
        @product = Product.find_by_permalink(params[:id])
    end
	filter :name
	#filter :permalink
	filter :code
	filter :price
	filter :created_at
	index do 
		selectable_column
		column :name do |p|
			link_to p.name, admin_product_path(p)
		end
		#column :permalink
		column "image" do |product|
		  image_tag product.photo.url, class: 'pic'
		end
		column :price
		column :created_at
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
		end
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

		end
	end
end