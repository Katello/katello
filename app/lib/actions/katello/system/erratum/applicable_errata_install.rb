module Actions
  module Katello
    module System
      module Erratum
        class ApplicableErrataInstall < Actions::EntryAction
          include Helpers::Presenter

          #takes a list of errata and schedules the installation of those that are applicable
          def plan(system, errata_uuids)
            applicable_errata = system.applicable_errata.where(:uuid => errata_uuids)
            plan_action(Actions::Katello::System::Erratum::Install, system, applicable_errata.pluck(:errata_id))
          end

          def humanized_name
            _("Install Applicable Errata")
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Katello::System::Erratum::Install))
          end
        end
      end
    end
  end
end
