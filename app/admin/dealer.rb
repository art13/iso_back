ActiveAdmin.register Dealer do
	filter :name
	filter :lastname
	filter :shopname
	filter :email
	filter :created_at
	actions :all, :except => [:new,:edit]

	index do 
		selectable_column
		column :name
		column :lastname
		column :shopname
		column :email
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