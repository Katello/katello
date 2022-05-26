module Actions
  module Katello
    module AlternateContentSource
      class Refresh < Actions::EntryAction
        def plan(acs)
          action_subject(acs)
          concurrence do
            acs.smart_proxies.each do |smart_proxy|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Refresh,
                          acs, smart_proxy)
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
