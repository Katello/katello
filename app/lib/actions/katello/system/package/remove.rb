module Actions
  module Katello
    module System
      module Package
        class Remove < Actions::EntryAction
          include Helpers::Presenter

          def plan(system, packages)
            action_subject(system, :packages => packages)
            plan_action(Pulp::Consumer::ContentUninstall,
                        consumer_uuid: system.uuid,
                        type:          'rpm',
                        args:          packages)
          end

          def humanized_name
            _("Remove package")
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
        end
      end
    end
  end
end
