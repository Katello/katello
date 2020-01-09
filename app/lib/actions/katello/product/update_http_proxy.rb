module Actions
  module Katello
    module Product
      class UpdateHttpProxy < Actions::EntryAction
        def plan(products, http_proxy_policy, http_proxy)
          products.each do |product|
            roots = product.root_repositories
            next if roots.empty?
            plan_action(::Actions::BulkAction,
                        ::Actions::Katello::Repository::Update,
                        roots,
                        http_proxy_policy: http_proxy_policy,
                        http_proxy_id: http_proxy&.id)
          end
        end
      end
    end
  end
end
