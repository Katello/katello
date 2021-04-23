module Actions
  module Katello
    module Host
      class AutoAttachSubscriptions < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def queue
          ::Katello::HOST_TASKS_QUEUE
        end

        def plan(host)
          action_subject(host)
          plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, :uuid => host.subscription_facet.uuid)
        end

        def resource_locks
          :link
        end
      end
    end
  end
end
