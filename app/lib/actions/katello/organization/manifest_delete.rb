module Actions
  module Katello
    module Organization
      class ManifestDelete < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        include Helpers::Notifications

        def plan(organization)
          action_subject(organization)

          sequence do
            plan_action(Candlepin::Owner::DestroyImports, label: organization.label)

            if SETTINGS[:katello][:use_pulp]
              organization.products.redhat.flat_map(&:repositories).each do |repo|
                plan_action(Katello::Repository::RefreshRepository, repo)
              end
            end
            plan_self
          end
        end

        def failure_notification(plan)
          ::Katello::UINotifications::Subscriptions::ManifestDeleteError.deliver!(
            :subject => subject_organization,
            :task => get_foreman_task(plan)
          )
        end

        def success_notification(_plan)
          ::Katello::UINotifications::Subscriptions::ManifestDeleteSuccess.deliver!(
            subject_organization
          )
        end

        def humanized_name
          _("Delete Manifest")
        end

        def finalize
          subject_organization.update_attributes!(
            :manifest_refreshed_at => Time.now,
            :audit_comment => _('Manifest deleted'))
        end
      end
    end
  end
end
