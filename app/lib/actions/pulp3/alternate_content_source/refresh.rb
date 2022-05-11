module Actions
  module Pulp3
    module AlternateContentSource
      class Refresh < Pulp3::AbstractAsyncTask
        def plan(acs, smart_proxy)
          plan_self(acs_id: acs.id, smart_proxy_id: smart_proxy.id)
        end

        def invoke_external_task
          acs = ::Katello::AlternateContentSource.find(input[:acs_id])
          output[:response] = acs.backend_service(smart_proxy).refresh
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
