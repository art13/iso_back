Rails.application.routes.draw do
		devise_for :admin_users, ActiveAdmin::Devise.config
	 	ActiveAdmin.routes(self)
		#resources :products, :only => [:index, :show]
		namespace :api do 
			resources :categories, :only => [:index, :show]
		  	resources :products, :only => [:index, :show]
			# scope :v1 do 
	 		mount_devise_token_auth_for 'Dealer', at: 'dealers'
	  		mount_devise_token_auth_for 'Customer', at: 'customers'
				# resources :dealers
				# as :customer do
				#     # Define routes for Customer within this block.
				# end
				# as :dealer do
				#     # Define routes for Dealer within this block.
				# end
			#end
		end
		
end
