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
