module Katello
  module ProxyStatus
    class PulpNode < Katello::ProxyStatus::Pulp
      def self.humanized_name
        'PulpNode'
      end
    end
  end
end
::ProxyStatus.status_registry.add(Katello::ProxyStatus::PulpNode)
