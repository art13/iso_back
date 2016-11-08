class Api::ApiController < ActionController::Base
	include DeviseTokenAuth::Concerns::SetUserByTokens
end