module Actions
  module Pulp3
    module CapsuleContent
      class ValidateContent < Pulp3::AbstractAsyncTask
        def resource_locks
          :link
        end

        input_format do
          param :name
        end

        def humanized_name
          _("Validate content smart proxy")
        end

        def humanized_input
          input['smart_proxy'].nil? || input['smart_proxy']['name'].nil? ? super : ["'#{input['smart_proxy']['name']}'"] + super
        end

        def plan(smart_proxy)
          action_subject(smart_proxy)
          plan_self(smart_proxy_id: smart_proxy.id)
        end

        def invoke_external_task
          output[:pulp_tasks] = ::Katello::Pulp3::Api::Core.new(SmartProxy.find(input[:smart_proxy_id])).
            repair_all
        end
      end
    end
  end
end
