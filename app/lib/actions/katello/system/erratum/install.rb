module Actions
  module Katello
    module System
      module Erratum
        class Install < Actions::EntryAction
          include Helpers::Presenter

          def plan(system, errata_ids)
            Type! system, ::Katello::System

            action_subject(system, :errata => errata_ids)
            plan_action(Pulp::Consumer::ContentInstall,
                        consumer_uuid: system.uuid,
                        type:          'erratum',
                        args:          errata_ids)
          end

          def humanized_name
            _("Install erratum")
          end

          def humanized_input
            [input[:errata].join(", ")] + super
          end

          def resource_locks
            :link
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Pulp::Consumer::ContentInstall))
          end
        end
      end
    end
  end
end
