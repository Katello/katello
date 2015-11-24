module Actions
  module Katello
    module Host
      class AutoAttachSubscriptions < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(host)
          action_subject(host)
          plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, :uuid => host.subscription_facet.uuid)
        end

        def finalize
          ::Katello::Pool.import_all
        end

        def resource_locks
          :link
        end
      end
    end
  end
end
