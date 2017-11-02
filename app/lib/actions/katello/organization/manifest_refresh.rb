module Actions
  module Katello
    module Organization
      class ManifestRefresh < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        def plan(organization)
          action_subject organization
          manifest_update = organization.products.redhat.any?
          path = "/tmp/#{rand}.zip"
          details  = organization.owner_details
          upstream = details['upstreamConsumer'].blank? ? {} : details['upstreamConsumer']

          sequence do
            upstream_update = plan_action(Candlepin::Owner::UpstreamUpdate,
                        :organization_id => organization.id,
                        :upstream => upstream)
            export_action = plan_action(Candlepin::Owner::UpstreamExport,
                        :organization_id => organization.id,
                        :upstream => upstream,
                        :path => path,
                        :dependency => upstream_update.output)
            owner_import = plan_action(Candlepin::Owner::Import,
                        :label => organization.label,
                        :path => path,
                        :dependency => export_action.output)
            import_products = plan_action(Candlepin::Owner::ImportProducts, :organization_id => organization.id, :dependency => owner_import.output)

            if manifest_update && SETTINGS[:katello][:use_pulp]
              repositories = ::Katello::Repository.in_default_view.where(:product_id => ::Katello::Product.redhat.in_org(organization))
              repositories.each do |repo|
                plan_action(Katello::Repository::RefreshRepository, repo, :dependency => import_products.output)
              end
            end
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Refresh Manifest")
        end
      end
    end
  end
end
