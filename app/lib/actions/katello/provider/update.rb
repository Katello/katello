module Actions
  module Katello
    module Provider
      class Update < Actions::EntryAction
        def plan(provider, params)
          action_subject(provider)

          update_url(provider, params[:redhat_repository_url]) if params[:redhat_repository_url]
        end

        def humanized_name
          _("Update")
        end

        private

        def update_url(provider, base_url)
          provider.update!(:repository_url => base_url)

          if provider.redhat_provider?
            provider.products.enabled.each do |product|
              update_repository_urls(product)
            end
          end
        end

        def update_repository_urls(product)
          product.repositories.where(:library_instance_id => nil).each do |repository|
            next unless repository.url
            root = repository.root
            url = root.repo_mapper.feed_url
            plan_action(::Actions::Katello::Repository::Update, root, :url => url)
          end
        end
      end
    end
  end
end
