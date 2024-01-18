module Actions
  module Katello
    module Product
      class Destroy < Actions::EntryAction
        def plan(product, options = {})
          organization_destroy = options.fetch(:organization_destroy, false)
          skip_environment_update = options.fetch(:skip_environment_update, false) ||
              options.fetch(:organization_destroy, false)
          check_ready_to_delete(product, organization_destroy)
          action_subject(product)

          # Candlepin::Product::ContentRemove is called with Katello::Repository::Destroy, so we only want to run ContentRemove
          # on repos that are not being destroyed with Katello::Repository::Destroy.
          content_ids = product.repositories.in_default_view.map(&:content_id)
          remaining_product_content = product.product_contents.select { |content| !content_ids.include?(content.content.cp_content_id) }

          sequence do
            unless organization_destroy
              sequence do
                # ContentDestroy must be called sequentially due to Candlepin's
                # issues with running multiple remove_content calls at the same time.
                plan_content_destruction(product, skip_environment_update)
              end
              concurrence do
                plan_repo_destruction(product, options)
              end
              plan_action(Candlepin::Product::DeletePools,
                            cp_id: product.cp_id, organization_label: product.organization.label)
              plan_action(Candlepin::Product::DeleteSubscriptions,
                            cp_id: product.cp_id, organization_label: product.organization.label)

              concurrence do
                remaining_product_content.each do |pc|
                  plan_action(Candlepin::Product::ContentRemove,
                              owner: product.organization.label,
                              product_id: product.cp_id,
                              content_id: pc.content.cp_content_id)
                end
              end

              plan_action(Candlepin::Product::Destroy, cp_id: product.cp_id, :owner => product.organization.label)
            end

            clear_pool_associations(product)

            plan_self(:product_id => product.id)
          end
        end

        def finalize
          product = ::Katello::Product.find(input[:product_id])
          product.destroy!
        end

        def humanized_name
          _("Delete Product")
        end

        def clear_pool_associations(product)
          product.pool_products.delete_all
        end

        def plan_content_destruction(product, skip_environment_update)
          product.repositories.in_default_view.each do |repo|
            if repo.root.repositories.where.not(id: repo.id).empty? &&
                !repo.redhat? &&
                !skip_environment_update
              plan_action(::Actions::Katello::Product::ContentDestroy, repo.root)
            end
          end
        end

        def plan_repo_destruction(product, options)
          product.repositories.in_default_view.each do |repo|
            repo_options = options.clone
            plan_action(Katello::Repository::Destroy, repo, **repo_options.merge(destroy_content: false))
          end
        end

        def view_versions(product)
          cvvs = product.published_content_view_versions.uniq
          views = cvvs.inject({}) do |result, version|
            result[version.content_view.name] ||= []
            result[version.content_view.name] << version.version
            result
          end
          results = views.map do |view, versions|
            _("Content View %{view}: Versions: %{versions}") % {:view => view, :versions => versions.join(', ')}
          end
          results.join(', ')
        end

        def check_ready_to_delete(product, organization_destroy)
          unless organization_destroy || product.user_deletable?
            if product.redhat?
              fail _("Cannot delete Red Hat product: %{product}") % { :product => product.name }
            elsif !product.published_content_view_versions.not_ignorable.empty?
              fail _("Cannot delete product with repositories published in a content view.  Product: %{product}, %{view_versions}") %
                     { :product => product.name, :view_versions => view_versions(product) }
            elsif product.repositories.any? { |repo| repo.filters.any? { |filter| filter.repositories.size == 1 } }
              fail _("Cannot delete product: %{product} with repositories that are the last affected repository in content view filters. Delete these repositories before deleting product.") %
                     { :product => product.name }
            end
          end
        end
      end
    end
  end
end
