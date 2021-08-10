module Actions
  module Katello
    module Repository
      class Create < Actions::EntryAction
        def plan(repository, args = {})
          clone = args[:clone] || false
          force_repo_create = args[:force_repo_create] || false
          repository.save!
          root = repository.root

          action_subject(repository)

          org = repository.organization
          pulp2_create_action = plan_create ? Actions::Pulp::Repository::CreateInPlan : Actions::Pulp::Repository::Create
          sequence do
            create_action = plan_action(Pulp3::Orchestration::Repository::Create,
                                        repository, SmartProxy.pulp_primary, force_repo_create)

            return if create_action.error

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
              view_env = org.default_content_view.content_view_environment(org.library)
              if repository.product.redhat?
                plan_action(Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => view_env.cp_id, :content_id => repository.content_id)
              else
                unless root.content
                  content_create = plan_action(Katello::Product::ContentCreate, root)
                  plan_action(Actions::Candlepin::Environment::AddContentToEnvironment, :view_env_cp_id => view_env.cp_id, :content_id => content_create.input[:content_id])
                end
              end
            end

            concurrence do
              plan_self(:repository_id => repository.id, :clone => clone)
            end
          end
        end

        def run
          ::User.current = ::User.anonymous_api_admin
          unless input[:clone]
            repository = ::Katello::Repository.find(input[:repository_id])
            ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
          end
        ensure
          ::User.current = nil
        end

        def humanized_name
          _("Create")
        end
      end
    end
  end
end
