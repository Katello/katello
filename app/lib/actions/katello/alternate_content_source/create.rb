module Actions
  module Katello
    module AlternateContentSource
      class Create < Actions::EntryAction
        def plan(acs, smart_proxies)
          acs.save!
          action_subject(acs)
          sequence do
            smart_proxies.each do |smart_proxy|
              ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id)
              plan_action(Pulp3::Orchestration::AlternateContentSource::Create,
                          acs, smart_proxy)
            end
          end
        end

        def humanized_name
          _("Create Alternate Content Source")
        end
      end
    end
  end
end
