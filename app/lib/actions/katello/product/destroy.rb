module Actions
  module Katello
    module Product
      class Destroy < Actions::EntryAction
        # rubocop:disable MethodLength
        def plan(product, options = {})
          organization_destroy = options.fetch(:organization_destroy, false)

          unless organization_destroy || product.user_deletable?
            if product.redhat?
              fail _("Cannot delete Red Hat product: %{product}") % { :product => product.name }
            elsif !product.published_content_view_versions.empty?
              fail _("Cannot delete product with repositories published in a content view.  Product: %{product}, %{view_versions}") %
                       { :product => product.name, :view_versions => view_versions(product) }
            end
          end

          action_subject(product)

          sequence do
            unless organization_destroy
              concurrence do
                product.repositories.in_default_view.each do |repo|
                  repo_options = options.clone
                  repo_options[:planned_destroy] = true
                  plan_action(Katello::Repository::Destroy, repo, repo_options)
                end
              end
              concurrence do
                plan_action(Candlepin::Product::DeletePools,
                              cp_id: product.cp_id, organization_label: product.organization.label)
                plan_action(Candlepin::Product::DeleteSubscriptions,
                              cp_id: product.cp_id, organization_label: product.organization.label)
              end
            end

            if !product.used_by_another_org? && !organization_destroy
              concurrence do
                product.productContent.each do |pc|
                  plan_action(Candlepin::Product::ContentRemove,
                              product_id: product.cp_id,
                              content_id: pc.content.id)
                end
              end
              plan_action(Candlepin::Product::Destroy, cp_id: product.cp_id)
            end

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
      end
    end
  end
end
