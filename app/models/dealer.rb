class Dealer < ApplicationRecord
  	# Include default devise modules.
  	devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,:omniauthable, omniauth_providers: [:vkontakte]
         # :confirmable, 
  	include DeviseTokenAuth::Concerns::User
end
