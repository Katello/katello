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
          unless env.deletable?
            fail env.errors.full_messages.join(" ")
          end
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
              env.hostgroups.clear
              env.hosts.clear
            end

            plan_self
          end
        end

        def humanized_name
          _("Delete Lifecycle Environment")
        end

        def humanized_input
          ["'#{input['kt_environment']['name']}'"] + super
        end

        def finalize
          environment = ::Katello::KTEnvironment.find(input['kt_environment']['id'])
          environment.destroy!
        end
      end
    end
  end
end
