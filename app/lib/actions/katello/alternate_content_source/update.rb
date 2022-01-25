module Actions
  module Katello
    module AlternateContentSource
      class Update < Actions::EntryAction
        def plan(acs, smart_proxies, acs_params)
          action_subject(acs)
          acs.update!(acs_params)
          smart_proxies = smart_proxies.uniq

          smart_proxies_to_add = smart_proxies - acs.smart_proxies
          smart_proxies_to_delete = acs.smart_proxies - smart_proxies
          smart_proxies_to_update = smart_proxies & acs.smart_proxies

          concurrence do
            smart_proxies_to_add.each do |smart_proxy|
              ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id)
              plan_action(Pulp3::Orchestration::AlternateContentSource::Create,
                          acs, smart_proxy)
            end

            smart_proxies_to_delete.each do |smart_proxy|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Delete,
                          acs, smart_proxy)
            end

            smart_proxies_to_update.each do |smart_proxy|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Update,
                          acs, smart_proxy)
            end
          end
        end

        def humanized_name
          _("Update Alternate Content Source")
        end
      end
    end
  end
end
