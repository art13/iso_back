class Api::ApiController < ApplicationController
	#protect_from_forgery with: :null_session
	include DeviseTokenAuth::Concerns::SetUserByTokens
	respond_to :json
end