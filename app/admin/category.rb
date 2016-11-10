ActiveAdmin.register Category do
	config.filters = false
	permit_params :name, :site_permalink, :permalink, :parent_id, :parent
	#filter :name
	# filter :permalink
	# filter :parent
	# filter :created_at
	sortable tree: true,
			sorting_attribute: :id,
			collapsible: true,
			start_collapsed: true,
			roots_collection: proc { @categories.where("parent_id =? or parent_id=?",  nil, 0) } 
	index :as => :sortable do
	    label  :name# item content
	    actions
	end
	# index do 
	# 	selectable_column
	# 	column :name
	# 	column :permalink
	# 	column :created_at
	# 	column :parent
	# 	column "Sub Categories" do |category|
	#       	children = category.children
	# 	    if children.present?
	# 	        render :partial => "children", :locals => { :children => children }
	# 	    end
 #    	end
	# 	actions
	# end
	form do |f|
		f.inputs do
			 f.input :name
			 f.input :parent, :as => :select, include_blank: true
			 f.input :site_permalink
		end
		f.actions
	end 
	show do |category|  
		attributes_table do
		 row :name
		 row :permalink
		 row :created_at
		 row :parent
		end
	end
	controller do
	    before_filter only: :index do
	      if table_presenter?
	        active_admin_config.paginate = true
	        active_admin_config.filters  = true
	      end
	    end

	    def presenter_config
	      active_admin_config.get_page_presenter(action_name, params[:as]) || {}
	    end

	    def sortable_presenter?
	      presenter_config[:as] == :sortable
	    end

	    def table_presenter?
	      presenter_config[:as] == :table
	    end
	end
end