class Api::ApiController < ActionController::Base
	before_action :authenticate_user!
	protect_from_forgery with: :null_session
	before_filter :configure_permitted_parameters, if: :devise_controller?

	protected

	def configure_permitted_parameters
	    devise_parameter_sanitizer.permit(:registration, keys: [:name, :nickname, :lastname])
	end
	puts "popopos"
	include DeviseTokenAuth::Concerns::SetUserByTokens
end