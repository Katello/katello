module Actions
  module Pulp3
    module CapsuleContent
      class VerifyChecksum < Pulp3::AbstractAsyncTask
        def plan(smart_proxy)
          action_subject(smart_proxy)
          plan_self(smart_proxy_id: smart_proxy.id)
        end

        def invoke_external_task
          output[:pulp_tasks] = ::Katello::Pulp3::Api::Core.new(SmartProxy.find(input[:smart_proxy_id])).repair
        end
      end
    end
  end
end
