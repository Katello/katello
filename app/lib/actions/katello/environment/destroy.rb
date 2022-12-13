module Actions
  module Katello
    module Environment
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        input_format do
          param :id
          param :name
        end

        def plan(env, options = {})
          fail env.errors.full_messages.join(" ") unless env.deletable?

          skip_repo_destroy = options.fetch(:skip_repo_destroy, false)
          organization_destroy = options.fetch(:organization_destroy, false)
          sequence do
            action_subject(env)

            concurrence do
              env.content_view_environments.each do |cve|
                plan_action(ContentView::Remove, cve.content_view, :content_view_environments => [cve], :skip_repo_destroy => skip_repo_destroy, :organization_destroy => organization_destroy)
              end
            end

            if organization_destroy
              delete_host_and_hostgroup_associations(environment: env)
            end

            plan_self
          end
        end

        def delete_host_and_hostgroup_associations(environment:)
          environment.hostgroups.delete_all
          host_ids = environment.hosts.ids
          ::Katello::Host::ContentFacet.where(:host_id => host_ids).delete_all
          ::Katello::Host::SubscriptionFacet.where(:host_id => host_ids).delete_all
        end

        def humanized_name
          _("Delete Lifecycle Environment")
        end

        def humanized_input
          ["'#{input['kt_environment']['name']}'"] + super
        end

        def finalize
          environment = ::Katello::KTEnvironment.find(input['kt_environment']['id'])

          # CapsuleLifecycleEnvironment can cause issues when auditing, it will try to associate the audit to the deleted taxonomy
          ::Katello::CapsuleLifecycleEnvironment.without_auditing do
            environment.destroy!
          end
        end
      end
    end
  end
end
