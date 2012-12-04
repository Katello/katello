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

class Ping
  class << self

    #
    # Calls "status" services in all backend engines.
    #
    # This should be called as 'admin' user otherwise the oauth will fail.
    #
    def ping
      if Katello.config.katello?
        result = { :result => 'ok', :status => {
          :pulp => {},
          :candlepin => {},
          :elasticsearch => {},
          :pulp_auth => {},
          :candlepin_auth => {},
          :katello_jobs => {},
          :foreman_auth => {},
        }}
      else
        result = { :result => 'ok', :status => {
          :candlepin => {},
          :elasticsearch => {},
          :candlepin_auth => {},
          :katello_jobs => {}
        }}
      end

      # pulp - ping without oauth
      if Katello.config.katello?
        url = Katello.config.pulp.url
        exception_watch(result[:status][:pulp]) do
          RestClient.get "#{url}/services/status/"
        end
      end

      # candlepin - ping without oauth
      url = Katello.config.candlepin.url
      exception_watch(result[:status][:candlepin]) do
        RestClient.get "#{url}/status"
      end

      # elasticsearch - ping without oauth
      url = Katello.config.elastic_url
      exception_watch(result[:status][:elasticsearch]) do
        RestClient.get "#{url}/_status"
      end

      # pulp - ping with oauth
      if Katello.config.katello?
        exception_watch(result[:status][:pulp_auth]) do
          Resources::Pulp::PulpPing.ping
        end
      end

      # candlepin - ping with oauth
      exception_watch(result[:status][:candlepin_auth]) do
        Resources::Candlepin::CandlepinPing.ping
      end

      # foreman - ping with oauth
      exception_watch(result[:status][:foreman_auth]) do
        Resources::Foreman::Home.status({}, Resources::ForemanModel.header)
      end

      # katello jobs - TODO we should not spawn processes
      exception_watch(result[:status][:katello_jobs]) do
        raise _("katello-jobs service not running") if !system("/sbin/service katello-jobs status")
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
      rescue => e
        Rails.logger.warn(e.backtrace ? [e.message, e.backtrace].join("\n") : e.message)
        result[:result] = 'fail'
        result[:message] = e.message
      end
    end

    # get package information for katello and its components
    def packages
      packages = `rpm -qa | egrep "katello|candlepin|pulp|thumbslug|qpid|foreman|ldap_fluff"`
      packages.split("\n").sort
    end
  end
end

#:nocov:
