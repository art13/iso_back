Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
	resources :products, :only => [:index, :show]
	namespace :api do 
	  	resources :categories, :only => [:index]
	  	resources :products, :only => [:index, :show]
	end
end
