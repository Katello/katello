module Actions
  module Katello
    module Host
      module PackageGroup
        class Install < Actions::Katello::AgentAction
          def plan(host, groups)
            Type! host, ::Host::Managed

            action_subject(host, :groups => groups)

            plan_self(:host_id => host.id, :groups => groups)
          end

          def dispatch_agent_action
            ::Katello::Agent::Dispatcher.dispatch(
              :install_package_group,
              host_id: input[:host_id],
              groups: input[:groups]
            )
          end

          def agent_action_type
            :content_install
          end

          def humanized_name
            _("Install package group")
          end

          def humanized_input
            [input[:groups].join(", ")] + super
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: (_("Installation of package group(s) requested: %{groups}") % {groups: input[:groups].join(", ")}).truncate(255))
          end
        end
      end
    end
  end
end
