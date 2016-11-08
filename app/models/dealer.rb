class Dealer < ApplicationRecord
  	# Include default devise modules.
  	devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :trackable, :validatable,:omniauthable
         # :confirmable, 
  	validates_presence_of :uid, :provider
  	validates_uniqueness_of :uid, :scope => :provider
  	include DeviseTokenAuth::Concerns::User

	def self.find_for_oauth(auth)
	    find_or_create_by(uid: auth.uid, provider: auth.provider)
	end
end
