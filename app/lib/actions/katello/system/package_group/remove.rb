module Actions
  module Katello
    module System
      module PackageGroup
        class Remove < Actions::EntryAction
          include Helpers::Presenter

          def plan(system, groups)
            action_subject(system, :groups => groups)
            plan_action(Pulp::Consumer::ContentUninstall,
                        consumer_uuid: system.uuid,
                        type:          'package_group',
                        args:          groups)
          end

          def humanized_name
            _("Remove package group")
          end

          def humanized_input
            [input[:groups].join(', ')] + super
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
