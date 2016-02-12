require 'active_support'
require "#{Katello::Engine.root}/app/services/cert/rhsm_client.rb"

module Katello
  module Authentication
    module ClientAuthentication
      def authenticate_client
        set_client_user
        User.current.present?
      end

      def set_client_user
        if cert_present?
          client_cert = ::Cert::RhsmClient.new(cert_from_request)
          uuid = client_cert.uuid
          User.current = CpConsumerUser.new do |cp_consumer|
            cp_consumer.uuid = uuid
            cp_consumer.login = uuid
          end
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
