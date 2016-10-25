module Actions
  module Katello
    module Organization
      class ManifestImport < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        def plan(organization, path, force)
          action_subject organization
          manifest_update = organization.products.redhat.any?

          sequence do
            plan_action(Candlepin::Owner::Import,
                        :label => organization.label,
                        :path => path,
                        :force => force)
            plan_action(Candlepin::Owner::ImportProducts, :organization_id => organization.id)

            if manifest_update && SETTINGS[:katello][:use_pulp]
              organization.products.redhat.flat_map(&:repositories).each do |repo|
                plan_action(Katello::Repository::RefreshRepository, repo)
              end
            end
          end
        end

        def humanized_name
          _("Import Manifest")
        end
      end
    end
  end
end
