#
# Copyright 2012 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
module Katello
  class Logging
    def initialize
      Dir.mkdir_p "#{Rails.root}/log" unless File.directory?("#{Rails.root}/log")
      configure_color_scheme
    end

    def configuration
      Katello.config.logging
    end

    def root_configuration
      configuration.loggers.root
    end

    def configure(options = {})
      configure_root_logger(options)
      configure_children_loggers

      # you can add specific files per logger easily like this
      #   Logging.logger['sql'].appenders = Logging.appenders.file("#{Rails.env}_sql.log")
    end

    def configure_children_loggers
      loggers_hash = configuration.loggers.to_hash
      loggers_hash.keys.tap { |a| a.delete(:root) }.each do |logger|
        logger_config = configuration.loggers[logger]
        logger_object = ::Logging.logger[logger]
        logger_object.level = logger_config.level if logger_config.has_key?(:level)
        logger_object.additive = logger_config.enabled if logger_config.has_key?(:enabled)
      end
    end

    def configure_root_logger(options)
      ::Logging.logger.root.level     = root_configuration.level
      root_appender                   = build_root_appender(options)
      ::Logging.logger.root.appenders = root_appender

      # fallback to log to STDOUT if there is any configuration problem
      if ::Logging.logger.root.appenders.empty?
        ::Logging.logger.root.appenders = ::Logging.appenders.stdout
        ::Logging.logger.root.warn 'No appender set, logging to STDOUT'
      end
    end

    def build_root_appender(options)
      name = "#{options[:prefix]}joined"
      case root_configuration.type
        when 'syslog'
          ::Logging.appenders.syslog(
              name,
              options.reverse_merge(:ident    => "#{options[:prefix]}katello",
                                    :facility => ::Syslog::Constants::LOG_DAEMON)
          )
        when 'file'
          log_filename = "#{Rails.root}/log/#{options[:prefix]}#{root_configuration.filename}"
          ::Logging.appenders.rolling_file(
              name,
              options.reverse_merge(:filename => log_filename,
                                    :roll_by  => 'date',
                                    :age      => root_configuration.age,
                                    :keep     => root_configuration.keep,
                                    :layout   => build_layout(root_configuration.pattern, configuration.colorize))
          )
        else
          raise 'unsupported logger type, please choose syslog or file'
      end
    end

    def build_layout(pattern, colorize)
      ::Logging.layouts.pattern(:pattern => pattern, :color_scheme => colorize ? 'bright' : nil)
    end

    def configure_color_scheme
      ::Logging.color_scheme('bright',
                             :levels => {
                                 :info  => :green,
                                 :warn  => :yellow,
                                 :error => :red,
                                 :fatal => [:white, :on_red]
                             },
                             :date   => :blue,
                             :logger => :cyan,
      )
    end

    # We need a bridge for Tire so we can log their messages to our logger
    class TireBridge
      def initialize(logger)
        @logger = logger
      end

      # text representation of logger level
      def level
        ::Logging.levelify(::Logging::LNAMES[@logger.level])
      end

      # actual bridge to katello logger
      # we enforce debug level so messages can be easily turned on/off by setting info level
      # to tire_rest logger
      def write(message)
        @logger.debug message
      end
    end
  end
end