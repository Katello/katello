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
            cp_import_task = plan_action(Candlepin::Owner::Import,
                        :label => organization.label,
                        :path => path,
                        :force => force)
            concurrence do
              plan_action(
                Candlepin::Owner::AsyncImport,
                :task_id => cp_import_task.output[:task_id]
              )
              plan_action(Candlepin::Owner::ImportProducts, :organization_id => organization.id)
            end

            if manifest_update
              repositories = ::Katello::Repository.in_default_view.in_product(::Katello::Product.redhat.in_org(organization))
              repositories.each do |repo|
                plan_action(Katello::Repository::RefreshRepository, repo)
              end
            end
            plan_self(candlepin_task: cp_import_task.output[:task])
          end
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
          [
            [:organization, {
              :text=>"for organization '#{input[:organization_name]}'",
              :link=>"/organizations/#{input[:organization_id]}/edit"
            }]
          ]
        end

        def run
          output[:candlepin_task] = input[:candlepin_task]
        end

        def finalize
          subject_organization.clear_manifest_expired_notifications
          subject_organization.audit_manifest_action(_('Manifest imported'))
        end
      end
    end
  end
end
