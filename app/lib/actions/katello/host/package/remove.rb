module Actions
  module Katello
    module Host
      module Package
        class Remove < Actions::EntryAction
          include Helpers::Presenter

          def plan(host, packages)
            action_subject(host, :hostname => host.name, :packages => packages)
            plan_action(Pulp::Consumer::ContentUninstall,
                        consumer_uuid: host.content_facet.uuid,
                        type:          'rpm',
                        args:          packages)
            plan_self(:host_id => host.id)
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

          def presenter
            Helpers::Presenter::Delegated.new(
                self, planned_actions(Pulp::Consumer::ContentUninstall))
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
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
