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
            plan_action(Candlepin::Owner::UpstreamUpdate,
                        :organization_id => organization.id,
                        :upstream => upstream)
            plan_action(Candlepin::Owner::UpstreamExport,
                        :organization_id => organization.id,
                        :upstream => upstream,
                        :path => path)
            plan_action(Candlepin::Owner::Import,
                        :label => organization.label,
                        :path => path)
            plan_action(Candlepin::Owner::ImportProducts, :organization_id => organization.id)

            if manifest_update && SETTINGS[:katello][:use_pulp]
              organization.products.redhat.flat_map(&:repositories).each do |repo|
                plan_action(Katello::Repository::RefreshRepository, repo)
              end
            end
          end
        end

        def humanized_name
          _("Refresh Manifest")
        end
      end
    end
  end
end
