Src::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
end

class ActiveRecord::Base
  def self.establish_connection(*args)
    # do nothing - we don't need to have database installed to run
    # this environments.
  end
end
