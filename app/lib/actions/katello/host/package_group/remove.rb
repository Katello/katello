module Actions
  module Katello
    module Host
      module PackageGroup
        class Remove < Actions::Katello::AgentAction
          def plan(host, groups)
            action_subject(host, :groups => groups)
            plan_self(:host_id => host.id, groups: groups)
          end

          def dispatch_agent_action
            ::Katello::Agent::Dispatcher.dispatch(
              :remove_package_group,
              host_id: input[:host_id],
              groups: input[:groups]
            )
          end

          def agent_action_type
            :content_uninstall
          end

          def humanized_name
            _("Remove package group")
          end

          def humanized_input
            [input[:groups].join(', ')] + super
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: (_("Removal of package group(s) requested: %{groups}") % {groups: input[:groups].join(", ")}).truncate(255))
          end
        end
      end
    end
  end
end
