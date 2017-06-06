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
  config.action_controller.perform_caching = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Be sure to restart your server when you modify this file.
  config.session_store :cookie_store, :key => '_katello_session_development'

  #support for reloadable Runcible
  #config.autoload_paths += %W(#{Rails.root}/../../runcible/lib)
  #ActiveSupport::Dependencies.explicitly_unloadable_constants << "::Runcible::Resources"
  #ActiveSupport::Dependencies.explicitly_unloadable_constants << "::Runcible::Extensions"

  #Developemtn asset pipeline settings
  config.assets.compile   = true
  config.assets.compress  = false
  config.assets.debug     = true

  Bundler.require(:debugging, Rails.env)
end
