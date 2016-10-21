ActiveAdmin.register Customer do
	filter :name
	filter :lastname
	filter :nickname
	filter :email
	filter :phone
	filter :created_at
	actions :all, :except => [:new,:edit]

	index do 
		selectable_column
		column :name
		column :lastname
		column :nickname
		column :email
		column :phone
	end
	form do |f|
	    f.inputs "Customers" do
	      f.input :name
	      f.input :lastname
	      f.input :nickname
	      f.input :email
	      f.input :phone
	      f.input :password
	      f.input :password_confirmation
	    end
	    f.actions
	end
	show  :download_links => false do |user|  
		attributes_table do
	        row :name
	        row :lastname 
	        row :nickname
	        row :email
	        row :phone
	        row :created_at
	        row :current_sign_in_at
	        row :last_sign_in_at
	        row :sign_in_count
	    end
    end
end