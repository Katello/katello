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
              repositories = ::Katello::Repository.in_default_view.in_product(::Katello::Product.redhat.in_org(organization))
              repositories.each do |repo|
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
          subject_organization.clear_syspurpose_status if subject_organization.simple_content_access?(cached: false)
          subject_organization.audit_manifest_action(_('Manifest deleted'))
        end
      end
    end
  end
end
