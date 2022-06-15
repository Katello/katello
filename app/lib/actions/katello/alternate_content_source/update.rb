module Actions
  module Katello
    module AlternateContentSource
      class Update < Actions::EntryAction
        # smart_proxies ALWAYS represents the smart proxies to remain associated
        # after the action runs.  If smart_proxies == [], there will be none afterwards.
        # The same rule applies to products.
        def plan(acs, smart_proxies, products, acs_params)
          action_subject(acs)
          acs.update!(acs_params)

          smart_proxies = smart_proxies.uniq
          smart_proxies_to_add = smart_proxies - acs.smart_proxies
          smart_proxies_to_delete = acs.smart_proxies - smart_proxies
          smart_proxies_to_update = smart_proxies & acs.smart_proxies

          products = products.uniq
          products_to_add = products - acs.products
          products_to_delete = acs.products - products
          acs.products = products

          concurrence do
            smart_proxies_to_add&.each do |smart_proxy|
              if acs.custom?
                smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id)
                plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
              elsif acs.simplified?
                acs.products.each do |product|
                  product.repositories.library.with_type(acs.content_type).each do |repo|
                    smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repo.id)
                    plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
                  end
                end
              end
            end

            smart_proxies_to_delete&.each do |smart_proxy|
              acs.smart_proxy_alternate_content_sources.where(smart_proxy_id: smart_proxy.id).each do |smart_proxy_acs|
                plan_action(Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
              end
            end

            smart_proxies_to_update&.each do |smart_proxy|
              if acs.custom?
                smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.find_by(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: nil)
                plan_action(Pulp3::Orchestration::AlternateContentSource::Update, smart_proxy_acs)
              elsif acs.simplified?
                products_to_add.each do |product|
                  product.repositories.library.with_type(acs.content_type).each do |repo|
                    smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repo.id)
                    plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
                  end
                end
                products_to_delete.each do |product|
                  product.repositories.library.with_type(acs.content_type).each do |repo|
                    smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.find_by(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repo.id)
                    plan_action(Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
                  end
                end
              end
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
