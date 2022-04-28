module Actions
  module Pulp3
    module AlternateContentSource
      class Update < Pulp3::Abstract
        def plan(acs, smart_proxy)
          plan_self(:acs_id => acs.id, :smart_proxy_id => smart_proxy.id)
        end

        def run
          acs = ::Katello::AlternateContentSource.find(input[:acs_id])
          output[:response] = acs.backend_service(smart_proxy).update
        end
      end
    end
  end
end
