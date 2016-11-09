class ApiController < ActionController::Bases
	include DeviseTokenAuth::Concerns::SetUserByTokens
end