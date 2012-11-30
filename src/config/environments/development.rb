Src::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false
  #config.cache_classes = true
  #switch the above to true if you're demoing.

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_view.debug_rjs             = true
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # See everything in the log (default is :info)
  config.log_level = :debug
  config.colorize_logging = false
  Dir.mkdir "#{Rails.root}/log" unless File.directory? "#{Rails.root}/log"
  config.active_record.logger = Logger.new("#{Rails.root}/log/development_sql.log")
end
