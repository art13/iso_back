Rails.application.config.middleware.use OmniAuth::Builder do
	provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  	provider :facebook,      ENV['FACEBOOK_KEY'], ENV['FACEBOOK_SECRET']
  	provider :google_oauth2, ENV['GOOGLE_KEY'],   ENV['GOOGLE_SECRET']
  	provider :vkontakte, ENV['VK_KEY'],   ENV['VK_SECRET']
end