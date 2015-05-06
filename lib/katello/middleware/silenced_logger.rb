module Katello
  module Middleware
    class SilencedLogger < Rails::Rack::Logger
      def prefixes
        Katello.config.logging.ignored_paths
      end

      def initialize(app, _options = {})
        @app = app
      end

      def call(env)
        old_level = Rails.logger.level
        if prefixes.any? { |path|  env["PATH_INFO"].include?(path) }
          Rails.logger.level = Logger::WARN
        end
        @app.call(env)
      ensure
        Rails.logger.level = old_level
      end
    end
  end
end
