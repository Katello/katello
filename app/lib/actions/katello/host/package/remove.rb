module Actions
  module Katello
    module Host
      module Package
        class Remove < Actions::Katello::AgentAction
          def plan(host, packages)
            action_subject(host, :hostname => host.name, :packages => packages)

            plan_self(:host_id => host.id, :packages => packages)
          end

          def dispatch_agent_action
            ::Katello::Agent::Dispatcher.dispatch(
              :remove_package,
              host_id: input[:host_id],
              packages: input[:packages]
            )
          end

          def agent_action_type
            :content_uninstall
          end

          def humanized_name
            if input.try(:[], :hostname)
              _("Remove package for %s") % input[:hostname]
            else
              _("Remove package")
            end
          end

          def humanized_input
            [humanized_package_names.join(', ')] + super
          end

          def humanized_package_names
            input[:packages].inject([]) do |result, package|
              if package.is_a?(Hash)
                new_name = package.include?(:name) ? package[:name] : ""
                new_name += '-' + package[:version] if package.include?(:version)
                new_name += '.' + package[:release] if package.include?(:release)
                new_name += '.' + package[:arch] if package.include?(:arch)
                result << new_name
              else
                result << package
              end
            end
          end

          def finalize
            host = ::Host.find_by(:id => input[:host_id])
            host.update(audit_comment: (_("Removal of package(s) requested: %{packages}") % {packages: input[:packages].join(", ")}).truncate(255))
          end
        end
      end
    end
  end
end
