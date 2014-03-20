#
# Copyright 2013 Red Hat, Inc.
#
# This software is licensed to you under the GNU General Public
# License as published by the Free Software Foundation; either version
# 2 of the License (GPLv2) or (at your option) any later version.
# There is NO WARRANTY for this software, express or implied,
# including the implied warranties of MERCHANTABILITY,
# NON-INFRINGEMENT, or FITNESS FOR A PARTICULAR PURPOSE. You should
# have received a copy of GPLv2 along with this software; if not, see
# http://www.gnu.org/licenses/old-licenses/gpl-2.0.txt.

require 'rhsm/cert'

module Katello
  module Authentication
    module RhsmClientAuthentication
      extend ActiveSupport::Concern

      included do

        def authorize_client
          ssl_client_cert = cert_from_request

          if ssl_client_cert.present? && ssl_client_cert != "(null)"
            rhsm_cert = Rhsm::Cert.new(cert_from_request)
            uuid = rhsm_cert.uuid
            User.current = CpConsumerUser.new(:uuid => uuid, :login => uuid, :remote_id => uuid)
          elsif authenticate
            User.current
          else
            deny_access
          end
        end

        def cert_from_request
          request.env['SSL_CLIENT_CERT'] ||
          request.env['HTTP_SSL_CLIENT_CERT'] ||
          ENV['SSL_CLIENT_CERT'] ||
          ENV['HTTP_SSL_CLIENT_CERT']
        end

        def add_candlepin_version_header
          response.headers["X-CANDLEPIN-VERSION"] = "katello/#{Katello.config.katello_version}"
        end

      end

    end
  end
end
