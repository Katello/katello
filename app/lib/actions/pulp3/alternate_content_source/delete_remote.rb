module Actions
  module Pulp3
    module AlternateContentSource
      class DeleteRemote < Pulp3::AbstractAsyncTask
        def plan(acs, smart_proxy)
          plan_self(:acs_id => acs.id, :smart_proxy_id => smart_proxy.id)
        end

        def invoke_external_task
          acs = ::Katello::AlternateContentSource.find(input[:acs_id])
          output[:response] = acs.backend_service(smart_proxy).delete_remote
        end
      end
    end
  end
end
