Src::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = false

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
end
