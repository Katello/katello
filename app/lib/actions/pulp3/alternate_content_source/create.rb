module Actions
  module Pulp3
    module AlternateContentSource
      class Create < Pulp3::Abstract
        def plan(smart_proxy_acs)
          plan_self(smart_proxy_id: smart_proxy_acs.smart_proxy_id, smart_proxy_acs_id: smart_proxy_acs.id)
        end

        def run
          smart_proxy_acs_id = input[:smart_proxy_acs_id]
          smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.find(smart_proxy_acs_id)
          output[:response] = smart_proxy_acs.backend_service.create
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
