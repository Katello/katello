module Actions
  module Katello
    module Environment
      class PublishRepositories < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        input_format do
          param :id
          param :name
        end

        def plan(env, options = {})
          repositories = options[:content_type] ? env.repositories.where(content_type: options[:content_type]) : env.repositories
          action_subject(env)
          concurrence do
            repositories.each do |repository|
              sequence do
                plan_action(::Actions::Katello::Repository::Update, repository, container_repository_name: repository.container_repository_name)
                plan_action(::Actions::Katello::Repository::CapsuleSync, repository)
              end
            end

            plan_self
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end

        def humanized_name
          _("Publish Lifecycle Environment Repositories")
        end

        def humanized_input
          input['kt_environment'].nil? ? super : ["'#{input['kt_environment']['name']}'"] + super
        end
      end
    end
  end
end
