module Actions
  module Katello
    module Organization
      class ManifestRefresh < Actions::AbstractAsyncTask
        middleware.use Actions::Middleware::PropagateCandlepinErrors

        include Helpers::Notifications

        def plan(organization)
          action_subject organization
          manifest_update = organization.products.redhat.any?
          path = File.join(::Rails.root, "tmp", "#{rand}.zip")
          details = organization.owner_details
          upstream = details['upstreamConsumer'].blank? ? {} : details['upstreamConsumer']

          sequence do
            plan_self(
              :organization_id => organization.id,
              :organization_name => organization.name
            )
            upstream_update = plan_action(Candlepin::Owner::UpstreamUpdate,
                        { :organization_id => organization.id,
                          :upstream => upstream })
            export_action = plan_action(Candlepin::Owner::StartUpstreamExport,
                        { :organization_id => organization.id,
                          :upstream => upstream,
                          :path => path,
                          :dependency => upstream_update.output })
            retrieved_export = plan_action(Candlepin::Owner::RetrieveUpstreamExport,
                        { :export_id => export_action.output[:task]['resultData']['exportId'],
                          :organization_id => organization.id,
                          :upstream => upstream,
                          :path => path,
                          :dependency => export_action.output })
            owner_import = plan_action(Candlepin::Owner::Import,
                        { :label => organization.label,
                          :path => path,
                          :dependency => retrieved_export.output })
            import_products = plan_action(Candlepin::Owner::ImportProducts,
              { :organization_id => organization.id,
                :dependency => owner_import.output })
            plan_action(Katello::Organization::EnvironmentContentsRefresh,
              organization)
            if manifest_update
              plan_refresh_repos(import_products, organization)
            end
          end
        end

        def plan_refresh_repos(import_products_action, org)
          repositories = ::Katello::Repository.in_default_view.in_product(::Katello::Product.redhat.in_org(org))
          repositories.in_groups_of(Setting[:foreman_proxy_content_batch_size], false) do |repo_batch|
            concurrence do
              repo_batch.each do |repo|
                plan_action(Katello::Repository::RefreshRepository,
                  repo,
                  :dependency => import_products_action.output)
              end
            end
          end
        end

        def failure_notification(plan)
          ::Katello::UINotifications::Subscriptions::ManifestRefreshError.deliver!(
            :subject => subject_organization,
            :task => get_foreman_task(plan)
          )
        end

        def success_notification(_plan)
          ::Katello::UINotifications::Subscriptions::ManifestRefreshSuccess.deliver!(
            subject_organization
          )
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Refresh Manifest")
        end

        # results in correct grammar on Tasks page,
        # e.g. "Refresh manifest for organization Default Organization"
        def humanized_input
          "for organization '#{input[:organization_name]}'"
        end

        def humanized_output
          all_planned_actions(Candlepin::Owner::Import).first.humanized_output
        end

        def finalize
          org = ::Organization.find(input[:organization_id])
          org.clear_manifest_expired_notifications
          subject_organization.audit_manifest_action(_('Manifest refreshed'))
        end
      end
    end
  end
end
