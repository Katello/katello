module Actions
  module Katello
    module System
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, options = {})
          pool_ids = system.pools.map { |x| x["id"] }
          skip_candlepin = options.fetch(:skip_candlepin, false)
          skip_pulp = system.hypervisor?
          action_subject(system)

          concurrence do
            plan_action(Candlepin::Consumer::Destroy, uuid: system.uuid) unless skip_candlepin
            plan_action(Pulp::Consumer::Destroy, uuid: system.uuid) unless skip_pulp
          end

          plan_self(:system_id => system.id, :pool_ids => pool_ids)
        end

        def finalize
          system = ::Katello::System.find(input[:system_id])
          system.destroy!
          input[:pool_ids].each do |pool_id|
            pool = ::Katello::Pool.where(:cp_id => pool_id).first
            pool.import_data if pool
          end
        end

        def humanized_name
          _("Destroy Content Host")
        end
      end
    end
  end
end
