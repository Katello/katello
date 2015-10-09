module Actions
  module Katello
    module System
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, sys_params)
          system.disable_auto_reindex!
          action_subject system
          system.update_attributes!(sys_params)
          system.update_foreman_facts
          sequence do
            concurrence do
              plan_action(::Actions::Pulp::Consumer::Update, system) if !system.hypervisor? && ::SETTINGS[:katello][:use_pulp]
              plan_action(::Actions::Candlepin::Consumer::Update, system) if ::SETTINGS[:katello][:use_cp]
            end

            if sys_params[:autoheal] && ::SETTINGS[:katello][:use_cp]
              plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, system)
            end
            plan_action(ElasticSearch::Reindex, system) if ::SETTINGS[:katello][:use_elasticsearch]
          end
        end
      end
    end
  end
end
