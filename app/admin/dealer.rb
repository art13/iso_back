ActiveAdmin.register Dealer do
	# batch_actions =>  false	
	filter :name
	filter :lastname
	filter :shopname
	filter :email
	filter :created_at
	actions :all, :except => [:new,:edit, :destroy]

	index do 
		selectable_column
		column :name
		column :lastname
		column :shopname
		column :email
		actions
	end
	form do |f|
	    f.inputs "Dealers" do
	      f.input :name
	      f.input :lastname
	      f.input :shopname
	      f.input :email
	      f.input :shop_url
	      f.input :password
	      f.input :password_confirmation
	    end
	    f.actions
	end
	show  :download_links => false do |user|  
		attributes_table do
	        row :name
	        row :lastname 
	        row :shopname
	        row :email
	        row :shop_url
	        row :created_at
	        row :current_sign_in_at
	        row :last_sign_in_at
	        row :sign_in_count
	    end
    end
end