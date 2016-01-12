require "proxy_api/pulp"

module Katello
  module ProxyStatus
    class Pulp < ::ProxyStatus::Base
      def initialize(proxy, opts = {})
        super proxy, opts, 'Pulp'
      end

      def pulp_status
        Rails.cache.fetch(cache_key, :expires_in => cache_duration) do
          fetch_proxy_data do
            @api.status
          end
        end
      end

      def cache_key
        "proxy_#{proxy.id}/pulp"
      end

      def self.humanized_name
        'Pulp'
      end
    end
  end
end
