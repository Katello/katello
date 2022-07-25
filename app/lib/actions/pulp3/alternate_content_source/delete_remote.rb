module Actions
  module Pulp3
    module AlternateContentSource
      class DeleteRemote < Pulp3::AbstractAsyncTask
        def plan(smart_proxy_acs, options = {})
          plan_self(smart_proxy_id: smart_proxy_acs.smart_proxy_id, smart_proxy_acs_id: smart_proxy_acs.id, old_url: options[:old_url])
        end

        def invoke_external_task
          smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.find(input[:smart_proxy_acs_id])
          output[:response] = smart_proxy_acs.backend_service.delete_remote(old_url: input[:old_url])
        end
      end
    end
  end
end
