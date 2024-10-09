module Actions
  module Katello
    module Product
      class ContentCreate < Actions::Base
        middleware.use Actions::Middleware::RemoteAction

        def plan(repository)
          root = repository.root
          sequence do
            if repository.content_id.nil? || repository.content_id == 'INITIAL_DUMMY_VALUE'
              content_create = plan_action(Candlepin::Product::ContentCreate,
                                           repository_id: repository.id,
                                           owner:         root.organization.label,
                                           name:          root.name,
                                           type:          root.content_type,
                                           arches:        root.format_arches,
                                           label:         root.custom_content_label,
                                           content_url:   root.custom_content_path,
                                           os_versions:   root.os_versions&.join(','))
              content_id = content_create.output[:response][:id]
              plan_action(Candlepin::Product::ContentAdd, owner: root.product.organization.label,
                                    product_id: root.product.cp_id,
                                    content_id: content_id)

            else
              content_id = repository.content_id
            end

            plan_self(root_repository_id: root.id, repository_id: repository.id, content_id: content_id)

            if root.gpg_key
              plan_action(Candlepin::Product::ContentUpdate,
                          repository_id: repository.id,
                          owner:         root.organization.label,
                          name:          root.name,
                          type:          root.content_type,
                          arches:        root.format_arches,
                          label:         root.custom_content_label,
                          content_url:   root.custom_content_path,
                          gpg_key_url:   root.library_instance.yum_gpg_key_url)
            end
          end
        end

        def finalize
          root = ::Katello::RootRepository.find(input[:root_repository_id])
          content_url = root.custom_content_path
          if root.deb_using_structured_apt?
            repository = ::Katello::Repository.find(input[:repository_id])
            content_url += repository.deb_content_url_options
            repository.update(:content_id => input[:content_id])
          else
            root.update(:content_id => input[:content_id])
          end

          content = ::Katello::Content.where(organization_id: root.product.organization_id, cp_content_id: input[:content_id]).first_or_create do |new_content|
            new_content.name = root.name
            new_content.content_type = root.content_type
            new_content.label = root.custom_content_label
            new_content.content_url = content_url
            new_content.vendor = ::Katello::Provider::CUSTOM
          end

          # custom product content is always disabled by default
          ::Katello::ProductContent.where(product: root.product, content: content).first_or_create do |pc|
            pc.enabled = false
          end
        end
      end
    end
  end
end
