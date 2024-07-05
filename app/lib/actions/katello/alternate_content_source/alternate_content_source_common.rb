module Actions
  module Katello
    module AlternateContentSource
      module AlternateContentSourceCommon
        def create_simplified_acs(acs, smart_proxy)
          acs.products.each do |product|
            product.acs_compatible_repositories.with_type(acs.content_type).each do |repo|
              smart_proxy_acs = ::Katello::SmartProxyAlternateContentSource.create(alternate_content_source_id: acs.id, smart_proxy_id: smart_proxy.id, repository_id: repo.id)
              plan_action(Pulp3::Orchestration::AlternateContentSource::Create, smart_proxy_acs)
            end
          end
        end
      end
    end
  end
end
