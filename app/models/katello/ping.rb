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

#:nocov:

module Katello
  class Ping
    class << self
      OK_RETURN_CODE = 'ok'
      FAIL_RETURN_CODE = 'FAIL'
      PACKAGES = %w(katello candlepin pulp thumbslug qpid elasticsearch)

      #
      # Calls "status" services in all backend engines.
      #
      # This should be called with User.current set if you want to check pulp_auth
      #
      # TODO: break up this method
      # rubocop:disable MethodLength
      def ping
        if Katello.config.katello?
          result = { :status => OK_RETURN_CODE, :services => {
            :pulp => {},
            :candlepin => {},
            :elasticsearch => {},
            :pulp_auth => {},
            :candlepin_auth => {},
            :foreman_tasks => {},
          }}
        else
          result = { :status => OK_RETURN_CODE, :services => {
            :candlepin => {},
            :elasticsearch => {},
            :candlepin_auth => {},
            :foreman_tasks => {},
            :thumbslug => {}
          }}
        end

        # pulp - ping without oauth
        if Katello.config.katello?
          exception_watch(result[:services][:pulp]) do
            Ping.pulp_without_oauth
          end
        end

        # candlepin - ping without oauth
        url = Katello.config.candlepin.url
        exception_watch(result[:services][:candlepin]) do
          RestClient.get "#{url}/status"
        end

        # elasticsearch - ping without oauth
        url = Katello.config.elastic_url
        exception_watch(result[:services][:elasticsearch]) do
          RestClient.get "#{url}/_status"
        end

        # thumbslug - ping without authentication
        unless Katello.config.katello?
          url = Katello.config.thumbslug_url
          exception_watch(result[:services][:thumbslug]) do
            begin
              RestClient.get "#{url}/ping"
            # rubocop:disable HandleExceptions
            rescue OpenSSL::SSL::SSLError
              # We want to see this error, because it means that Thumbslug
              # is running and refused our (non-existent) ssl cert.
            end
          end
        end

        # pulp - ping with oauth
        if Katello.config.katello? && User.current
          exception_watch(result[:services][:pulp_auth]) do
            Katello.pulp_server.resources.user.retrieve_all
          end
        end

        # candlepin - ping with oauth
        exception_watch(result[:services][:candlepin_auth]) do
          Katello::Resources::Candlepin::CandlepinPing.ping
        end

        exception_watch(result[:services][:foreman_tasks]) do
          dynflow_world = ForemanTasks.dynflow.world
          if dynflow_world.executor.is_a?(Dynflow::Executors::RemoteViaSocket) &&
                !dynflow_world.executor.connected?
            fail _("foreman-tasks service not running")
          end
        end

        # set overall status result code
        result[:services].each_value do |v|
          result[:status] = FAIL_RETURN_CODE unless v[:status] == OK_RETURN_CODE
        end
        result
      end

      # check for exception - set the result code properly
      def exception_watch(result, &block)
        start = Time.new
        yield
        result[:status] = OK_RETURN_CODE
        result[:duration_ms] = ((Time.new - start) * 1000).round.to_s
      rescue => e
        Rails.logger.warn(e.backtrace ? [e.message, e.backtrace].join("\n") : e.message)
        result[:status] = FAIL_RETURN_CODE
        result[:message] = e.message
      end

      # get package information for katello and its components
      def packages
        names = PACKAGES.join("|")
        packages = `rpm -qa | egrep "#{names}"`
        packages.split("\n").sort
      end

      # this checks Pulp is running and responding without need
      # for authentication. We don't use RestClient.options here
      # because it returns empty string, which is not enough to say
      # pulp is the one that responded
      def pulp_without_oauth
        url = Katello.config.pulp.url
        uri = URI("#{url}/status/")
        http = Net::HTTP.new(uri.host, uri.port)
        if uri.scheme == "https"
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
        unless http.options(uri.path).content_length > 0
          fail _("Pulp not running")
        end
      end
    end
  end
end

#:nocov:
