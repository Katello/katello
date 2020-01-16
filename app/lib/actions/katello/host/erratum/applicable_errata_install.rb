module Actions
  module Katello
    module Host
      module Erratum
        class ApplicableErrataInstall < Actions::EntryAction
          include Helpers::Presenter

          #takes a list of errata and schedules the installation of those that are applicable
          def plan(host, options = {})
            fail _("errata_ids or update_all must be provided") if !options[:errata_ids] && !options[:update_all]
            errata_ids = options.fetch(:errata_ids, nil)

            applicable_errata = host.content_facet.applicable_errata
            applicable_errata = applicable_errata.with_identifiers(errata_ids) if errata_ids
            plan_action(Actions::Katello::Host::Erratum::Install, host, applicable_errata.pluck(:errata_id))
            plan_self(:hostname => host.name)
          end

          def humanized_name
            if input.try(:[], :hostname).nil?
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
