module Actions
  module Katello
    module AlternateContentSource
      class Destroy < Actions::EntryAction
        def plan(acs)
          action_subject(acs)
          sequence do
            acs.smart_proxies.each do |smart_proxy|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Destroy,
                          acs, smart_proxy)
            end
            plan_self(:acs_id => acs.id)
          end
        end

        def finalize
          acs = ::Katello::AlternateContentSource.find_by(id: input[:acs_id])
          acs.destroy
        end

        def humanized_name
          _("Destroy Alternate Content Source")
        end
      end
    end
  end
end
