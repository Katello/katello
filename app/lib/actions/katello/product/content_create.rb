module Actions
  module Katello
    module Product
      class ContentCreate < Actions::Base
        middleware.use Actions::Middleware::RemoteAction

        def plan(root)
          sequence do
            if root.content_id.nil?
              content_create = plan_action(Candlepin::Product::ContentCreate,
                                           owner:         root.product.organization.label,
                                           name:          root.name,
                                           type:          root.content_type,
                                           arches:        root.format_arches,
                                           label:         root.custom_content_label,
                                           os_versions:   root.os_versions&.join(','),
                                           content_url:   root.custom_content_path)
              content_id = content_create.output[:response][:id]
              plan_action(Candlepin::Product::ContentAdd, owner: root.product.organization.label,
                                    product_id: root.product.cp_id,
                                    content_id: content_id)

            else
              content_id = root.content_id
            end

            if root.gpg_key
              plan_action(Candlepin::Product::ContentUpdate,
                          owner:       root.organization.label,
                          content_id:  content_id,
                          name:        root.name,
                          type:        root.content_type,
                          arches:      root.format_arches,
                          label:       root.custom_content_label,
                          content_url: root.custom_content_path,
                          gpg_key_url: root.library_instance.yum_gpg_key_url)
            end

            plan_self(root_repository_id: root.id, content_id: content_id)
          end
        end

        def finalize
          root = ::Katello::RootRepository.find(input[:root_repository_id])
          root.update(:content_id => input[:content_id])

          content = ::Katello::Content.create!(name: root.name,
                                               organization_id: root.product.organization_id,
                                               cp_content_id: root.content_id,
                                               content_type: root.content_type,
                                               label: root.custom_content_label,
                                               content_url: root.custom_content_path,
                                               vendor: ::Katello::Provider::CUSTOM)

          #custom product content is always enabled by default
          ::Katello::ProductContent.create!(product: root.product, content: content, enabled: true)
        end
      end
    end
  end
end
