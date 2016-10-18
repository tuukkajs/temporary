Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, ENV['facebook_app_id'], ENV['facebook_secret'], callback_url: 'https://temporary.fi/users/auth/facebook/callback'
  provider :twitter, ENV['twitter_consumer_key'], ENV['twitter_consumer_secret']
  provider :google_oauth2, ENV["google_client_id"], ENV["google_client_secret"]
  provider :github, ENV['github_key'], ENV['github_secret']
end
