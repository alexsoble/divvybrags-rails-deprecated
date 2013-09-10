Rails.application.config.middleware.use OmniAuth::Builder do
  provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
  provider OmniAuth::Strategies::GoogleOauth2, ENV['GOOGLE_KEY'], ENV['GOOGLE_SECRET'], {
      :name => "google",
      :scope => "userinfo.profile, drive.file",
      :prompt => "select_account",
    }
end