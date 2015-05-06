module Actions
  module Katello
    module System
      class AutoAttachSubscriptions < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system)
          system.disable_auto_reindex!
          action_subject system
          plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, system) if ::Katello.config.use_cp
          plan_action(ElasticSearch::Reindex, system) if ::Katello.config.use_elasticsearch
        end
      end
    end
  end
end
