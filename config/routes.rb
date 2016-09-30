Rails.application.routes.draw do
	resources :products, :only => [:index, :show]
	namespace :api do 
	  	resources :categories, :only => [:index]
	  	resources :products, :only => [:index]
	end
end
