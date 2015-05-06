module Actions
  module Katello
    module Product
      class ContentCreate < Actions::Base
        middleware.use Actions::Middleware::RemoteAction

        def plan(repository)
          sequence do
            content_create = plan_action(Candlepin::Product::ContentCreate,
                                         name:        repository.name,
                                         type:        repository.content_type,
                                         label:       repository.custom_content_label,
                                         content_url: content_url(repository))

            plan_action(Candlepin::Product::ContentAdd,
                        product_id: repository.product.cp_id,
                        content_id: content_create.output[:response][:id])

            if repository.gpg_key
              plan_action(Candlepin::Product::ContentUpdate,
                          content_id:  content_create.output[:response][:id],
                          name:        repository.name,
                          type:        repository.content_type,
                          label:       repository.custom_content_label,
                          content_url: content_url(repository),
                          gpg_key_url: repository.yum_gpg_key_url)
            end

            plan_self(repository_id: repository.id,
                      content_id: content_create.output[:response][:id])
          end
        end

        def finalize
          repository = ::Katello::Repository.find(input[:repository_id])
          repository.content_id = input[:content_id]
          repository.save!
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
