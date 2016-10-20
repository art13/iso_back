ActiveAdmin.register Category do
	filter :name
	filter :permalink
	filter :parent
	filter :created_at
	index do 
		selectable_column
		column :name
		column :permalink
		column :created_at
		column :parent
		actions
	end
	show do |category|  
		attributes_table do
		 row :name
		 row :permalink
		 row :created_at
		 row :parent
		end
	end
end