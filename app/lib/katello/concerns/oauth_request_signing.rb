require 'oauth'

module Katello
  module Concerns
    module OauthRequestSigning
      extend ActiveSupport::Concern

      HTTP_CLASSES = {
        get: Net::HTTP::Get,
        post: Net::HTTP::Post,
        put: Net::HTTP::Put,
        patch: Net::HTTP::Patch,
        delete: Net::HTTP::Delete,
      }.freeze

      class_methods do
        def sign_request(req, url, method)
          fail "#{name}: OAuth consumer_key and consumer_secret required" if self.consumer_key.blank? || self.consumer_secret.blank?
          req.headers['Authorization'] = build_oauth_header(url, method)
        end

        private

        def oauth_consumer
          @oauth_consumer ||= OAuth::Consumer.new(
            self.consumer_key, self.consumer_secret,
            :site => self.site,
            :request_token_path => "",
            :authorize_path => "",
            :access_token_path => "",
            :ca_file => self.ssl_ca_file
          )
        end

        def build_oauth_header(url, method)
          request = HTTP_CLASSES.fetch(method).new(url)
          oauth_consumer.sign!(request)
          request['Authorization']
        end
      end
    end
  end
end
