class ApiController < ActionController::Base
	puts "getsss"
	include DeviseTokenAuth::Concerns::SetUserByTokens
end