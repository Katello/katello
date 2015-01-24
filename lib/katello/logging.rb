#
# Copyright 2014 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.
require 'logging'

module Katello
  class LoggingImpl
    private_class_method :new

    def configure(options = {})
      fail 'logging can be configured only once' if @configured
      @configured = true

      configure_color_scheme
      begin
        FileUtils.mkdir_p root_configuration.path unless File.directory?(root_configuration.path)
      rescue Errno::EACCES
        # just notify insufficient privileges
        # rubocop:disable Output
        puts "Insufficient privileges for #{root_configuration.path}"
      end
      configure_root_logger(options)
      integrate_yard_logger!
      configure_children_loggers

      if defined?(Rails::Console) && configuration.console_inline
        ::Logging.logger.root.add_appenders(
            ::Logging.appenders.stdout(:layout => build_layout(root_configuration.pattern, configuration.colorize)))
      end

      # you can add specific files per logger easily like this
      #   Logging.logger['sql'].appenders = Logging.appenders.file("#{Rails.env}_sql.log")
    end

    private

    # TODO: clean this up
    # rubocop:disable MethodLength, BlockAlignment
    def integrate_yard_logger!
      if defined?(::YARD)
        # redefine by YARD globally defined method #log to point to our logger
        Object.send :define_method, :log do
          Katello::LoggingImpl::YARDLoggerDelegator.instance
        end

        unless self.class.const_defined?(:YARDLoggerDelegator)
          # define our logger child for YARD
          self.class.const_set(:YARDLoggerDelegator, Class.new(::YARD::Logger) do
            # @return [::Logging::Logger] for yard
            def _logging_logger
              @_logging_logger ||= begin
                yard_logger_delegator = self
                ::Logging.logger['yard'].tap do |logger|
                  # redefine method #level= to set also YARD logger level
                  original_method = logger.method :level=
                  logger.singleton_class.send :define_method, :level= do |level|
                    yard_logger_delegator.instance_variable_set :@level, level
                    original_method.call level
                  end
                  logger.level = logger.level
                end
              end
            end

            # delegate all messages to a ::Logging::Logger
            def add(severity, message = nil, progname = nil, &block)
              clear_line
              #puts "-- #{severity} #{message || progname}"
              _logging_logger.add severity, message || progname, &block
            end

            # disable setting level by Yard logger
            def level=(_level)
              # debug "setting level:#{level} ignored, use Logging.logger['yard'].level= instead"
            end
          end)
        end
      end
    end

    # shortcut to logging configuration
    def configuration
      Katello.config.logging
    end

    # shortcut to root logger configuration
    def root_configuration
      configuration.loggers.root
    end

    # sets all children loggers according to configuration
    #
    # we use +additive+ feature of logging gem to enable or disable logger output, by default
    # only root logger has an appender so if we set +additive+ attribute to false, no message
    # is outputted by particular logger
    def configure_children_loggers
      # set level and enabled configuration
      loggers_hash = configuration.loggers.to_hash
      loggers_hash.keys.tap { |a| a.delete(:root) }.each do |logger_name|
        logger_config = configuration.loggers[logger_name]
        logger        = ::Logging.logger[logger_name]
        logger.level = logger_config.level if logger_config.key?(:level)
        logger.additive = logger_config.enabled if logger_config.key?(:enabled)
        enable_tailing logger, logger_config if logger_config.key?(:tail_command)
        logger.trace = configuration.log_trace
      end
    end

    # set root logger specific configuration
    #
    # root logger has configurable appender by argument +options+
    # we also set fallback appender to STDOUT in case a developer asks for unusable appender
    def configure_root_logger(options)
      ::Logging.logger.root.level     = root_configuration.level
      ::Logging.logger.root.appenders = build_root_appender(options)
      ::Logging.logger.root.trace     = configuration.log_trace

      # fallback to log to STDOUT if there is any configuration problem
      if ::Logging.logger.root.appenders.empty?
        ::Logging.logger.root.appenders = ::Logging.appenders.stdout
        ::Logging.logger.root.warn 'No appender set, logging to STDOUT'
      end
    end

    def enable_tailing(logger, logger_config)
      Thread.new do
        begin
          IO.popen(logger_config.tail_command) do |out|
            at_exit { Process.kill("INT", out.pid) }
            while (line = out.gets)
              logger << "[#{logger.name}] #{line.inspect}\n"
            end
          end
        rescue => e
          Logging.logger['app'].warn "tailing thread failed: #{e.message} (#{e.class})\n#{e.backtrace.join("\n")}"
        end
      end
    end

    # currently we support two types of appenders, rolling file and syslog
    # note that syslog ignores pattern and logs only messages
    def build_root_appender(options)
      name = "#{options[:prefix]}joined"
      case root_configuration[:type]
      when 'syslog'
        build_syslog_appender(name, options)
      when 'file'
        build_file_appender(name, options)
      else
        fail 'unsupported logger type, please choose syslog or file'
      end
    end

    def build_syslog_appender(name, options)
      ::Logging.appenders.syslog(
        name,
        options.reverse_merge(:ident    => "#{options[:prefix]}katello",
                              :facility => ::Syslog::Constants::LOG_DAEMON)
      )
    end

    def build_file_appender(name, options)
      path = root_configuration.path
      log_filename = "#{path}/#{options[:prefix]}#{root_configuration.filename}"
      begin
        ::Logging.appenders.rolling_file(
          name,
          options.reverse_merge(:filename => log_filename,
                                :roll_by  => 'date',
                                :age      => root_configuration.age,
                                :keep     => root_configuration.keep,
                                :layout   => build_layout(root_configuration.pattern, configuration.colorize))
        )
      rescue ArgumentError
        # if appender cannot open output file we ignore it, STDOUT fallback will be used
        nil
      end
    end

    def build_layout(pattern, colorize)
      pattern += "  Log trace: %F:%L method: %M\n" if configuration.log_trace
      MultilinePatternLayout.new(:pattern => pattern, :color_scheme => colorize ? 'bright' : nil)
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
                             :line   => :yellow,
                             :file   => :yellow,
                             :method => :yellow
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

    # Custom pattern layout that indents multiline strings and adds | symbol to beginning of each
    # following line hence you can see what belongs to the same message
    class MultilinePatternLayout < ::Logging::Layouts::Pattern
      def format_obj(obj)
        obj.is_a?(String) ? indent_lines(obj) : super
      end

      private

      # all new lines will be indented
      def indent_lines(string)
        string.gsub("\n", "\n | ")
      end
    end
  end

  Logging = LoggingImpl.send :new
end
