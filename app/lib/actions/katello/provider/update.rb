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
          provider.update_attributes!(:repository_url => base_url)

          if provider.redhat_provider?
            provider.products.enabled.each do |product|
              update_repository_urls(product, base_url)
            end
          end
        end

        def update_repository_urls(product, base_url)
          product.repositories.each do |repository|
            next unless repository.url
            uri = URI.parse(repository.url)
            url = "#{base_url}#{uri.path}"
            plan_action(::Actions::Katello::Repository::Update, repository, :url => url)
          end
        end
      end
    end
  end
end
