ActiveAdmin.register Product do

	batch_action :add_to_category, form: ->  {{
		  I18n.t("category") => Category.all.map{|t| [t.name, t.id]}
		} } do |ids, inputs|
		add_to_category(params["batch_action_inputs"],params["collection_selection"] )
	  #redirect_to collection_path
	end
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
	filter :admin_user, as: :select, :collection => AdminUser.all.map{|a| [a.email, a.id]}
	filter :category
	index do 
		selectable_column
		column :id
		column :name do |p|
			link_to p.name, admin_product_path(p)
		end
		column :image do |product|
		  image_tag product.photo.url, class: 'pic'
		end
		column :category
		column :price
		column :created_at
		column :updated_at
		column :admin_user
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
			f.input :description, :input_html => { :class => "tinymce" }
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
			row :image do |p|
				image_tag p.photo.url, class: 'row_pic'
			end
			row :category
			render :partial => "product_properties", :locals => {:properties => product.properties}
			row :updated_at
			row :admin_user

		end
	end
	controller do 
		def index 
			super
			@batch_categories = Category.order(:name).map{|t| [t.name, t.id]}	
			#logger.debug @batch_categories
		end

		def update
	      super do |format|
	        redirect_to collection_url and return if resource.valid?
	      end
	    end

		def add_to_category(category, product_ids)
			category_id = ActiveSupport::JSON.decode(category)[t("category")].to_i
			ids = product_ids.map{|a| a.to_i}
			Product.where(:id => ids).update_all(:category_id => category_id, :updated_at => Time.current, :admin_user_id  => current_admin_user.id) 
			redirect_to admin_products_path, :notice => t("update_all_products")
		end
	end
end