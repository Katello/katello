module Actions
  module Katello
    module AlternateContentSource
      class Create < Actions::EntryAction
        def plan(acs, smart_proxies, products)
          acs.save!
          action_subject(acs)
          acs.products << products
          smart_proxies = smart_proxies.uniq
          concurrence do
            smart_proxies.each do |smart_proxy|
              if acs.custom?
                smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id)
                plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
              else
                acs.products.each do |product|
                  product.repositories.with_type(acs.content_type).each do |repo|
                    smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repo.id)
                    plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
                  end
                end
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
