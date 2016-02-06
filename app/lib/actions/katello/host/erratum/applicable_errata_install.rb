module Actions
  module Katello
    module Host
      module Erratum
        class ApplicableErrataInstall < Actions::EntryAction
          include Helpers::Presenter

          #takes a list of errata and schedules the installation of those that are applicable
          def plan(host, errata_uuids)
            applicable_errata = host.content_facet.applicable_errata.where(:uuid => errata_uuids)
            plan_action(Actions::Katello::Host::Erratum::Install, host, applicable_errata.pluck(:errata_id))
            plan_self(:hostname => host.name)
          end

          def humanized_name
            if input[:hostname]
              _("Install Applicable Errata")
            else
              _("Install Applicable Errata on %s") % input[:hostname]
            end
          end

          def presenter
            Helpers::Presenter::Delegated.new(self, planned_actions(Katello::Host::Erratum::Install))
          end
        end
      end
    end
  end
end
