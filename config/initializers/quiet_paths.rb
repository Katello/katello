
PREFIXES = Katello.config.logging.ignored_paths
# Just create an alias for call in middleware
Rails::Rack::Logger.class_eval do

  def call_with_quiet(env)
    old_logger_level, level = Rails.logger.level, Logger::ERROR
    # Increase log level because of messages that have a low level should not be displayed
    quiet = PREFIXES.any?{|p|  env["PATH_INFO"].start_with?(p) }
    Rails.logger.level = level if quiet
    call_without_quiet(env)
  ensure
    # Return back
    Rails.logger.level = old_logger_level
  end

  alias_method_chain :call, :quiet

end
