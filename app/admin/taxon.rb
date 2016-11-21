ActiveAdmin.register Taxon do
	menu = false
	config.filters = false
	permit_params :name, :site_permalink, :permalink, :parent_id, :parent, :show_on_front, :position#, :lft, :rgt
	# batch_action :in_to_taxon, form: ->  {{
	# 	  I18n.t("category") => Taxon.all.map{|t| [t.name, t.id]}
	# 	} } do |ids, inputs|
	# 	in_to_category(params["batch_action_inputs"],params["collection_selection"] )
	# end
	sortable tree: true,
			sorting_attribute: :position,
			collapsible: true,
			start_collapsed: true,
			roots_collection: proc { @taxons.root_all } 
	index :as => :sortable do
	    label  :name
	    actions
	end
	form do |f|
		f.inputs do
			 f.input :name
			 f.input :parent, :as => :select, :collection =>  [""] + Taxon.all.map{|a| [a.name, a.id]} 
			 f.input :permalink
			 f.input :show_on_front
		end
		f.actions
	end 
	show do |category|  
		attributes_table do
		 row :name
		 row :permalink
		 row :created_at
		 row :parent
		 bool_row :show_on_front
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
	    # def create
	    #   super do |format|
	    #     redirect_to collection_url and return if resource.valid?
	    #   end
	    # end

	    def update
	      super do |format|
	        redirect_to collection_url and return if resource.valid?
	      end
	    end

	    # def in_to_category(category, ids)
	    # 	category_id = ActiveSupport::JSON.decode(category)[t("category")].to_i
	    # 	ids = ids.map{|i| i.to_i}
	    # 	@category = Category.find_by_id(category_id)
	    # 	Category.where(:id => ids).each do |category|
	    # 		category.products.update_all(:category_id => @category.id, :updated_at => Time.current, :admin_user_id  => current_admin_user.id)
	    # 		category.destroy if category != @category
	    # 	end
	    # 	redirect_to admin_categories_path, :notice => t("categories_shared_suc")
	    # end
	end
end