module Actions
  module Katello
    module System
      class AutoAttachSubscriptions < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        def plan(system)
          action_subject system
          plan_action(::Actions::Candlepin::Consumer::AutoAttachSubscriptions, system) if ::SETTINGS[:katello][:use_cp]
        end

        def finalize
          ::Katello::Pool.import_all
        end
      end
    end
  end
end
