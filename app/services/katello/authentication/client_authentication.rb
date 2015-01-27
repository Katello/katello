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

require 'active_support'
require File.expand_path('../../../client/cert.rb', __FILE__)

module Katello
  module Authentication
    module ClientAuthentication
      def authenticate_client
        set_client_user
        User.current.present?
      end

      def set_client_user
        if cert_present?
          client_cert = Client::Cert.new(cert_from_request)
          uuid = client_cert.uuid
          User.current = CpConsumerUser.new(:uuid => uuid, :login => uuid, :remote_id => uuid)
        end
      end

      def cert_present?
        ssl_client_cert = cert_from_request
        !ssl_client_cert.nil? && !ssl_client_cert.empty? && ssl_client_cert != "(null)"
      end

      # HTTP_X_RHSM_SSL_CLIENT_CERT - custom client cert header typically coming from a reverse
      #                               proxy on a Capsule passing RHSM traffic through in isolation
      # HTTP_SSL_CLIENT_CERT - standard client cert header coming from direct interactions with the
      #                        server
      def cert_from_request
        request.env['HTTP_X_RHSM_SSL_CLIENT_CERT'] ||
        request.env['SSL_CLIENT_CERT'] ||
        request.env['HTTP_SSL_CLIENT_CERT'] ||
        ENV['HTTP_X_RHSM_SSL_CLIENT_CERT'] ||
        ENV['SSL_CLIENT_CERT'] ||
        ENV['HTTP_SSL_CLIENT_CERT']
      end

      def add_candlepin_version_header
        response.headers["X-CANDLEPIN-VERSION"] = "katello/#{Katello::VERSION}"
      end
    end
  end
end
