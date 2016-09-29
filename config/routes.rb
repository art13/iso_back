Rails.application.routes.draw do
  namespace :api do 
  	resources :categories, :only => [:index]
  	resources :products, :only => [:index]
  end
end
