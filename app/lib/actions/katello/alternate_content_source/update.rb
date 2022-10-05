module Actions
  module Katello
    module AlternateContentSource
      class Update < Actions::EntryAction
        include Actions::Katello::AlternateContentSource::AlternateContentSourceCommon
        # smart_proxies ALWAYS represents the smart proxies to remain associated
        # after the action runs.  If smart_proxies == [], there will be none afterwards.
        # The same rule applies to products.
        def plan(acs, smart_proxies, products, acs_params)
          action_subject(acs)
          acs.update!(acs_params)

          smart_proxies = smart_proxies.uniq
          smart_proxies_to_associate = smart_proxies - acs.smart_proxies
          smart_proxies_to_disassociate = acs.smart_proxies - smart_proxies
          smart_proxies_to_update = smart_proxies & acs.smart_proxies

          products ||= []
          products_to_associate = []
          products_to_disassociate = []

          if acs.simplified?
            products = products.uniq
            products_to_associate = products - acs.products
            products_to_disassociate = acs.products - products
            old_product_ids = acs.products.pluck(:id)
            acs.products = products
            acs.audit_updated_products(old_product_ids) unless products_to_associate.empty? && products_to_disassociate.empty?
          end

          concurrence do
            create_acss(acs, smart_proxies_to_associate)
            delete_acss(acs, smart_proxies_to_disassociate)
            update_acss(acs, smart_proxies_to_update, products_to_associate, products_to_disassociate)
          end
        end

        def create_acss(acs, smart_proxies_to_associate)
          smart_proxies_to_associate&.each do |smart_proxy|
            if acs.custom? || acs.rhui?
              smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id)
              plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
            elsif acs.simplified?
              create_simplified_acs(acs, smart_proxy)
            end
          end
        end

        def delete_acss(acs, smart_proxies_to_disassociate)
          smart_proxies_to_disassociate&.each do |smart_proxy|
            acs.smart_proxy_alternate_content_sources.where(smart_proxy_id: smart_proxy.id).each do |smart_proxy_acs|
              plan_action(Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
            end
          end
        end

        def update_acss(acs, smart_proxies_to_update, products_to_associate, products_to_disassociate)
          smart_proxies_to_update&.each do |smart_proxy|
            if acs.custom? || acs.rhui?
              smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.find_by(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: nil)
              plan_action(Pulp3::Orchestration::AlternateContentSource::Update, smart_proxy_acs)
            elsif acs.simplified?
              products_to_associate.each do |product|
                product.repositories.library.with_type(acs.content_type).each do |repo|
                  smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repo.id)
                  plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
                end
              end
              products_to_disassociate.each do |product|
                product.repositories.library.with_type(acs.content_type).each do |repo|
                  smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.find_by(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repo.id)
                  plan_action(Pulp3::Orchestration::AlternateContentSource::Delete, smart_proxy_acs)
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
