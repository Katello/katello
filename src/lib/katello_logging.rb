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
    # production format: [severity date uuid #pid] message
    DEFAULT_PATTERNS = {
        :development => '%5l %m\n',
        :production  => '[%l %d %X{uuid} #%X{pid}] %m\n',
        :test        => '[%l %d %X{uuid} #%X{pid}] %m\n'
    }

    def initialize
      Dir.mkdir_p "#{Rails.root}/log" unless File.directory?("#{Rails.root}/log")
      configure_appenders
    end

    def configure
      level = Katello.config.log_level
      ::Logging.logger['app'].level             = level
      ::Logging.logger['sql'].level             = level
      ::Logging.logger['glue'].level            = level
      ::Logging.logger['pulp_rest'].level       = level
      ::Logging.logger['candlepin_rest'].level  = level
      ::Logging.logger['candlepin_proxy'].level = level
      ::Logging.logger['foreman_rest'].level    = level
      ::Logging.logger['tire_rest'].level       = level
      ::Logging.logger.root.appenders           = ::Logging.appenders['joined']
    end

    def configure_appenders
      ::Logging.appenders.rolling_file(
          'joined',
          :filename => "#{Rails.root}/log/#{Rails.env}.log",
          :roll_by  => 'date',
          :age      => 'weekly',
          :keep     => 2,
          :roll_by  => 'date',
          :layout   => katello_layout
      )

      # you can add specific files per logger easily like this
      #   Logging.logger['sql'].appenders = Logging.appenders.file("#{Rails.env}_sql.log")
    end

    def katello_layout
      ::Logging.layouts.pattern(:pattern => DEFAULT_PATTERNS[Rails.env.to_sym])
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
      def write(message)
        @logger.send level, message
      end
    end
  end
end