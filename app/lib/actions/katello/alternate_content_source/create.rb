module Actions
  module Katello
    module AlternateContentSource
      class Create < Actions::EntryAction
        include Actions::Katello::AlternateContentSource::AlternateContentSourceCommon

        def plan(acs, smart_proxies, products = nil)
          acs.save!
          action_subject(acs)
          acs.products << products if products.present?
          smart_proxies = smart_proxies.present? ? smart_proxies.uniq : []
          concurrence do
            smart_proxies.each do |smart_proxy|
              if acs.custom? || acs.rhui?
                smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id)
                plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
              elsif acs.simplified?
                create_simplified_acs(acs, smart_proxy)
              end
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
