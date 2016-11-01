Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
	resources :products, :only => [:index, :show]
	namespace :api do 
		namespace :v1 do 
 			mount_devise_token_auth_for 'Dealer', at: 'auth'
  			mount_devise_token_auth_for 'Customer', at: 'auth'
			as :customer do
			    # Define routes for Customer within this block.
			end
			as :dealer do
			    # Define routes for Dealer within this block.
			end
		end
	  	resources :categories, :only => [:index]
	  	resources :products, :only => [:index, :show]
	end
end
