module Actions
  module Katello
    module System
      module PackageGroup
        class Install < Actions::EntryAction
          include Helpers::Presenter

          def plan(system, groups)
            Type! system, ::Katello::System

            action_subject(system, :groups => groups)
            plan_action(Pulp::Consumer::ContentInstall,
                        consumer_uuid: system.uuid,
                        type:          'package_group',
                        args:          groups)
          end

          def humanized_name
            _("Install package group")
          end

          def humanized_input
            [input[:groups].join(", ")] + super
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Consumer::ContentInstall))
          end
        end
      end
    end
  end
end
