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
          current_base_url = provider.repository_url
          provider.update_attributes!(:repository_url => base_url)

          if provider.redhat_provider?
            provider.products.enabled.each do |product|
              update_repository_urls(product, current_base_url, base_url)
            end
          end
        end

        def update_repository_urls(product, current_base_url, new_base_url)
          product.repositories.each do |repository|
            next unless repository.url
            path = repository.url.split(current_base_url)[1]
            url = "#{new_base_url}#{path}"
            plan_action(::Actions::Katello::Repository::Update, repository, :url => url)
          end
        end
      end
    end
  end
end
