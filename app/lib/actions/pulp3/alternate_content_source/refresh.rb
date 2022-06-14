module Actions
  module Pulp3
    module AlternateContentSource
      class Refresh < Pulp3::AbstractAsyncTask
        def plan(smart_proxy_acs)
          plan_self(smart_proxy_id: smart_proxy_acs.smart_proxy_id, smart_proxy_acs_id: smart_proxy_acs.id)
        end

        def invoke_external_task
          smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.find(input[:smart_proxy_acs_id])
          output[:response] = smart_proxy_acs.backend_service.refresh
        end

        def rescue_strategy_for_self
          # There are various reasons why refreshing fails, but not all of them are
          # fatal. When failing to refresh, we continue with the task ending up
          # in the warning state, but don't lock further refreshing
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
