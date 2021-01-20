module Actions
  module Katello
    module Host
      module Package
        class Install < Actions::Katello::AgentAction
          def plan(host, packages)
            Type! host, ::Host::Managed

            action_subject(host, :hostname => host.name, :packages => packages)

            plan_self(:host_id => host.id, :packages => packages)
          end

          def dispatch_agent_action
            ::Katello::Agent::Dispatcher.dispatch(
              :install_package,
              host_id: input[:host_id],
              packages: input[:packages]
            )
          end

          def agent_action_type
            :content_install
          end

          def humanized_name
            if input.try(:[], :hostname)
              _("Install package for %s") % input[:hostname]
            else
              _("Install package")
            end
          end

          def humanized_input
            [input[:packages].join(", ")] + super
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: (_("Installation of package(s) requested: %{packages}") % {packages: input[:packages].join(", ")}).truncate(255))
          end
        end
      end
    end
  end
end
