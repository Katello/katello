module Actions
  module Katello
    module Organization
      module SimpleContentAccess
        class PrepareContentOverrides < Actions::Base
          def plan(organization_id)
            Rails.logger.info "PrepareContentOverrides plan: #{organization_id.inspect}"
            organization = ::Organization.find(organization_id.to_i)
            org_name = organization.name

            plan_self(organization_id: organization_id, organization_name: org_name)
          end

          def run
            organization = ::Organization.find(input[:organization_id].to_i)
            migrator = ::Katello::Util::ContentOverridesMigrator.new(organization: organization)

            output[:migrator_result] = migrator.execute_non_sca_overrides!
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end

          def humanized_name
            N_("Prepare content overrides for Simple Content Access")
          end

          def humanized_input
            _("for organization %s") % input[:organization_name]
          end
        end
      end
    end
  end
end
