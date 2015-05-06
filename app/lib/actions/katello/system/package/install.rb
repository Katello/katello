module Actions
  module Katello
    module System
      module Package
        class Install < Actions::EntryAction
          include Helpers::Presenter

          def plan(system, packages)
            Type! system, ::Katello::System

            action_subject(system, :packages => packages)
            plan_action(Pulp::Consumer::ContentInstall,
                        consumer_uuid: system.uuid,
                        type:          'rpm',
                        args:          packages)
          end

          def humanized_name
            _("Install package")
          end

          def humanized_input
            [input[:packages].join(", ")] + super
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Consumer::ContentInstall))
          end
        end
      end
    end
  end
end
