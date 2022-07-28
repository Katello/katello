module Actions
  module Katello
    module AlternateContentSource
      class Refresh < Actions::EntryAction
        def plan(acs)
          action_subject(acs)
          concurrence do
            acs.smart_proxy_alternate_content_sources.each do |smart_proxy_acs|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Refresh, smart_proxy_acs)
            end
          end
          plan_self(acs_id: acs.id)
        end

        def finalize
          ::Katello::AlternateContentSource.find_by(id: input[:acs_id])&.audit_refresh
        end

        def humanized_name
          _("Refresh Alternate Content Source")
        end
      end
    end
  end
end
