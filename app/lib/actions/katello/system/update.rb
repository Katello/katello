module Actions
  module Katello
    module System
      class Update < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system, sys_params)
          system.disable_auto_reindex!
          action_subject system
          system.update_attributes!(sys_params)
          sequence do
            concurrence do
              plan_action(::Actions::Pulp::Consumer::Update, system) if !system.hypervisor? && ::Katello.config.use_pulp
              plan_action(::Actions::Candlepin::Consumer::Update, system) if ::Katello.config.use_cp
            end

            if sys_params[:autoheal] && ::Katello.config.use_cp
              plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, system)
            end
            plan_action(ElasticSearch::Reindex, system) if ::Katello.config.use_elasticsearch
          end
        end
      end
    end
  end
end
