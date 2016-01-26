require 'uri'

module Katello
  module ProxyStatus
    class Pulp < ::ProxyStatus::Base
      def storage
        fetch_proxy_data do
          api.pulp_storage
        end
      end

      def status
        begin
          body = RestClient.get(pulp_url)
        rescue => e
          return {'fatal' => _('Unable to connect. Got: %s') % e}
        end
        fail _("Pulp does not appear to be running.") if body.empty?
        json = JSON.parse(body)
        json['errors'] = {}

        if json['known_workers'].empty?
          json['errors']['known_workers'] = _("No pulp workers running.")
        end

        if json['database_connection'] && json['database_connection']['connected'] != true
          json['errors']['database_connection'] = _("Pulp database connection issue.")
        end

        if json['messaging_connection'] && json['messaging_connection']['connected'] != true
          json['errors']['messaging_connection'] = _("Pulp message bus connection issue.")
        end

        json
      end

      def self.humanized_name
        'Pulp'
      end

      private

      def pulp_url
        url = URI.parse(proxy.url)
        url.port = 443
        url.path = '/pulp/api/v2/status/'
        url.to_s
      end
    end
  end
end
::ProxyStatus.status_registry.add(Katello::ProxyStatus::Pulp)
