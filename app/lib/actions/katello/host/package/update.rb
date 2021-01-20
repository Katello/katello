module Actions
  module Katello
    module Host
      module Package
        class Update < Actions::Katello::AgentAction
          def plan(host, packages)
            Type! host, ::Host::Managed

            action_subject(host, :hostname => host.name, :packages => packages)

            plan_self(:host_id => host.id, :packages => packages)
          end

          def dispatch_agent_action
            ::Katello::Agent::Dispatcher.dispatch(
              :update_package,
              host_id: input[:host_id],
              packages: input[:packages]
            )
          end

          def agent_action_type
            :content_install
          end

          def humanized_name
            if input.try(:[], :hostname)
              _("Update package for %s") % input[:hostname]
            else
              _("Update package")
            end
          end

          def humanized_input
            [(input[:packages].present? && input[:packages].join(", ") || "all packages")] + super
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: audit_comment)
          end

          def audit_comment
            if input[:packages].present?
              (_("Update of package(s) requested: %{packages}") % {packages: input[:packages].join(", ")}).truncate(255)
            else
              _("Update of all packages requested")
            end
          end
        end
      end
    end
  end
end
