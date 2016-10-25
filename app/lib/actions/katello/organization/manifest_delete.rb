module Actions
  module Katello
    module Organization
      class ManifestDelete < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        def plan(organization)
          action_subject(organization)

          sequence do
            plan_action(Candlepin::Owner::DestroyImports, label: organization.label)

            if SETTINGS[:katello][:use_pulp]
              organization.products.redhat.flat_map(&:repositories).each do |repo|
                plan_action(Katello::Repository::RefreshRepository, repo)
              end
            end
          end
        end

        def humanized_name
          _("Delete Manifest")
        end
      end
    end
  end
end
