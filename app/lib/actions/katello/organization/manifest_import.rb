module Actions
  module Katello
    module Organization
      class ManifestImport < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        include Helpers::Notifications

        def plan(organization, path, force)
          action_subject organization
          manifest_update = organization.products.redhat.any?

          sequence do
            plan_action(Candlepin::Owner::Import,
                        :label => organization.label,
                        :path => path,
                        :force => force)
            plan_action(Candlepin::Owner::ImportProducts, :organization_id => organization.id)

            if manifest_update
              repositories = ::Katello::Repository.in_default_view.in_product(::Katello::Product.redhat.in_org(organization))
              repositories.each do |repo|
                plan_action(Katello::Repository::RefreshRepository, repo)
              end
            end
            plan_self(:organization_name => organization.name)
          end
        end

        def run
          organization = ::Organization.find_by(name: input[:organization_name])
          organization&.manifest_expiration_date(cached: false) # update the date
        end

        def failure_notification(plan)
          ::Katello::UINotifications::Subscriptions::ManifestImportError.deliver!(
            :subject => subject_organization,
            :task => get_foreman_task(plan)
          )
        end

        def success_notification(_plan)
          ::Katello::UINotifications::Subscriptions::ManifestImportSuccess.deliver!(
            subject_organization
          )
        end

        def humanized_name
          _("Import Manifest")
        end

        # results in correct grammar on Tasks page,
        # e.g. "Import manifest for organization Default Organization"
        def humanized_input
          "for organization '#{input[:organization_name]}'"
        end

        def finalize
          subject_organization.clear_manifest_expired_notifications
          subject_organization.audit_manifest_action(_('Manifest imported'))
        end
      end
    end
  end
end
