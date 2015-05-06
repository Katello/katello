module Actions
  module Katello
    module System
      class HostDestroy < Actions::EntryAction
        def plan(host)
          action_subject(host)
          sequence do
            if host.content_host
              plan_action(Katello::System::Destroy, host.content_host)
            end
            plan_self(:host_id => host.id)
          end
        end

        def humanized_name
          _("Destroy Host")
        end

        def finalize
          host = Host.find(input[:host_id])
          unless host.reload.destroy
            fail host.errors.full_messages.join('; ')
          end
        end
      end
    end
  end
end
