Rails.application.routes.draw do
	resources :products, :only => [:index, :show]
	namespace :api do 
		resources :categories, :only => [:index]
	  	resources :products, :only => [:index, :show]
		scope :v1 do 
 			mount_devise_token_auth_for 'Dealer', at: 'auth'
  			mount_devise_token_auth_for 'Customer', at: 'auth'
			resources :customers
			resources :dealers
			# as :customer do
			#     # Define routes for Customer within this block.
			# end
			# as :dealer do
			#     # Define routes for Dealer within this block.
			# end
		end
	  	
	end
	devise_for :admin_users, ActiveAdmin::Devise.config
 	ActiveAdmin.routes(self)
end
