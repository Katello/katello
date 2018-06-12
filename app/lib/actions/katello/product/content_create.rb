module Actions
  module Katello
    module Product
      class ContentCreate < Actions::Base
        middleware.use Actions::Middleware::RemoteAction

        def plan(repository)
          sequence do
            if repository.content_id.nil?
              content_create = plan_action(Candlepin::Product::ContentCreate,
                                           owner:       repository.product.organization.label,
                                           name:        repository.name,
                                           type:        repository.content_type,
                                           arches:      repository.arch == "noarch" ? nil : repository.arch,
                                           label:       repository.custom_content_label,
                                           content_url: content_url(repository))
              content_id = content_create.output[:response][:id]
              plan_action(Candlepin::Product::ContentAdd, owner: repository.product.organization.label,
                                    product_id: repository.product.cp_id,
                                    content_id: content_id)

            else
              content_id = repository.content_id
            end

            if repository.gpg_key
              plan_action(Candlepin::Product::ContentUpdate,
                          owner:       repository.organization.label,
                          content_id:  content_id,
                          name:        repository.name,
                          type:        repository.content_type,
                          arches:      repository.arch == "noarch" ? "" : repository.arch,
                          label:       repository.custom_content_label,
                          content_url: content_url(repository),
                          gpg_key_url: repository.yum_gpg_key_url)
            end

            plan_self(repository_id: repository.id, content_id: content_id)
          end
        end

        def finalize
          repository = ::Katello::Repository.find(input[:repository_id])
          repository.content_id = input[:content_id]
          repository.save!

          content = ::Katello::Content.create!(name: repository.name,
                                               organization_id: repository.product.organization_id,
                                               cp_content_id: repository.content_id,
                                               content_type: repository.content_type,
                                               label: repository.custom_content_label,
                                               content_url: content_url(repository),
                                               vendor: ::Katello::Provider::CUSTOM)

          #custom product content is always enabled by default
          ::Katello::ProductContent.create!(product: repository.product, content: content, enabled: true)
        end

        private

        def content_url(repository)
          ::Katello::Glue::Pulp::Repos.custom_content_path(repository.product,
                                                           repository.label)
        end
      end
    end
  end
end
