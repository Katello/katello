#
# Copyright 2011 Red Hat, Inc.
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

require 'rest_client'
require 'resources/pulp'
require 'resources/candlepin'

class Ping
  class << self

    #
    # Calls "status" services in all backend engines.
    #
    # This should be called as 'admin' user otherwise the oauth will fail.
    #
    def ping
      result = { :result => 'ok', :status => {
        :pulp => {},
        :candlepin => {},
        :pulp_auth => {},
        :candlepin_auth => {},
      }}

      # pulp - ping without oauth
      url = AppConfig.pulp.url
      exception_watch(result[:status][:pulp]) do
        RestClient.get "#{url}/services/status/"
      end

      # candlepin - ping without oauth
      url = AppConfig.candlepin.url
      exception_watch(result[:status][:candlepin]) do
        RestClient.get "#{url}/status"
      end

      # pulp - ping with oauth
      exception_watch(result[:status][:pulp_auth]) do
        Pulp::PulpPing.ping
      end

      # candlepin - ping with oauth
      exception_watch(result[:status][:candlepin_auth]) do
        Candlepin::CandlepinPing.ping
      end

      # set overall status result code
      result[:status].each_value { |v| result[:result] = 'fail' if v[:result] != 'ok' }
      result
    end

    # check for exception - set the result code properly
    def exception_watch(result, &block)
      begin
        start = Time.new
        yield
        result[:result] = 'ok'
        result[:duration_ms] = ((Time.new - start) * 1000).round.to_s
      rescue Exception => e
        Rails.logger.warn(e.backtrace ? [e.message, e.backtrace].join("\n") : e.message)
        result[:result] = 'fail'
        result[:message] = e.message
      end
    end
  end
end

#:nocov:
