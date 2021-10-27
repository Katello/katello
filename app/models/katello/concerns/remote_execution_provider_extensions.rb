module Katello
  module Concerns
    module RemoteExecutionProviderExtensions
      def alternative_names(host)
        super.merge(:consumer_uuid => host.subscription_facet&.uuid)
      end
    end
  end
end
