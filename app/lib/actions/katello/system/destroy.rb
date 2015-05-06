module Actions
  module Katello
    module System
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, options = {})
          skip_candlepin = options.fetch(:skip_candlepin, false)
          skip_pulp = system.hypervisor?
          action_subject(system)

          concurrence do
            plan_action(Candlepin::Consumer::Destroy, uuid: system.uuid) unless skip_candlepin
            plan_action(Pulp::Consumer::Destroy, uuid: system.uuid) unless skip_pulp
          end

          plan_self(:system_id => system.id)
        end

        def finalize
          system = ::Katello::System.find(input[:system_id])
          system.destroy!
        end

        def humanized_name
          _("Destroy Content Host")
        end
      end
    end
  end
end
