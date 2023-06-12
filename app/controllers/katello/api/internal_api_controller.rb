module Katello
  module Api
    class InternalApiController < ApplicationController
      skip_before_action :verify_authenticity_token
      skip_before_action :require_login
      skip_before_action :session_expiry
      skip_before_action :authorize

      private

      def authorize_foreman_client
        client_cert = ::Foreman::ClientCertificate.new(request: request)
        render json: nil, status: :forbidden unless client_cert.verified?
      end
    end
  end
end
