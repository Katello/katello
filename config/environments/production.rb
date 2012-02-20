Src::Application.configure do
  class KatelloLogger < ActiveSupport::BufferedLogger
    def initialize(log, level)
      level = {
        "DEBUG" => 0,
        "INFO" => 1,
        "WARN" => 2,
        "ERROR" => 3,
        "FATAL" => 4
      }[level.upcase] if level.is_a? String
      super(log, level)
    end

    SEVERITY_TO_TEXT = ['DEBUG',' INFO',' WARN','ERROR','FATAL']

    def add(severity, message = nil, progname = nil, &block)
      status = SEVERITY_TO_TEXT[severity] || "UNKNOWN"
      unless level > severity
        message = (message || (block && block.call) || progname).to_s
        status = SEVERITY_TO_TEXT[severity] || "UNKNOWN"
        message = "[%s: %s #%d] %s" % [status,
                                       Time.now.strftime("%Y-%m-%d %H:%M:%S"),
                                       $$,
                                       message]
        super(severity, message)
      end
    end
  end

  # Settings specified here will take precedence over those in config/environment.rb

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Specifies the header that your server uses for sending files
  config.action_dispatch.x_sendfile_header = "X-Sendfile"

  # For nginx:
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'

  # If you have no front-end server that supports something like X-Sendfile,
  # just comment this out and Rails will serve the files

  # See everything in the log (default is :warn)
  config.log_level = (ENV['KATELLO_LOGGING'] || "warn").dup
  config.active_record.logger = Logger.new("#{Rails.root}/log/production_sql.log")
  config.colorize_logging = false

  # Use a different logger for distributed setups
  # config.logger = SyslogLogger.new

  prod_logger = KatelloLogger.new("#{Rails.root}/log/production.log", config.log_level)
  prod_logger.auto_flushing = 1
  config.logger = prod_logger
  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Disable Rails's static asset server
  # In production, Apache or nginx will already do this
  config.serve_static_assets = false

  # Enable serving of images, stylesheets, and javascripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false

  # Enable threaded mode
  # config.threadsafe!

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  # Do not update compass SASS files in production (we precompile them)
  Sass::Plugin.options[:never_update] = true
end
