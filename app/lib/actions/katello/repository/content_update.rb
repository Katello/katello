module Actions
  module Katello
    module Repository
      class ContentUpdate < Actions::Base
        def plan(repository, update_auto_enabled: false)
          root = repository.root
          content = root.content
          plan_action(::Actions::Candlepin::Product::ContentUpdate,
                      :owner => repository.organization.label,
                      :content_id => root.content_id,
                      :name => root.name,
                      :content_url => root.custom_content_path,
                      :gpg_key_url => repository.yum_gpg_key_url,
                      :label => content.label,
                      :type => root.content_type,
                      :arches => root.format_arches)

          if update_auto_enabled
            plan_action(::Actions::Candlepin::Product::ContentUpdateEnablement,
                        :owner => repository.organization.label,
                        :product_id => root.product.cp_id,
                        :content_enablements => root.content_enablements)
            plan_self(:repository_id => repository.id)
          end

          content.update!(name: root.name,
                                     content_url: root.custom_content_path,
                                     content_type: repository.content_type,
                                     label: content.label,
                                     gpg_url: repository.yum_gpg_key_url)
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ::Katello::ProductContent.where(:product => repository.product, :content => repository.content)
                                 .update(:enabled => repository.root.auto_enabled?)
        end
      end
    end
  end
end
