module Actions
  module Katello
    module Repository
      class Create < Actions::EntryAction
        def plan(repository, clone = false, plan_create = false)
          repository.save!
          root = repository.root

          action_subject(repository)

          org = repository.organization
          create_action = plan_create ? Actions::Pulp::Repository::CreateInPlan : Actions::Pulp::Repository::Create
          sequence do
            create_action = plan_action(create_action, repository)

            return if create_action.error

            # when creating a clone, the following actions are handled by the
            # publish/promote process
            unless clone
              if repository.product.redhat?
                plan_action(ContentView::UpdateEnvironment, org.default_content_view,
                            org.library, repository.content_id)
              else
                content_create = plan_action(Katello::Product::ContentCreate, root)
                plan_action(ContentView::UpdateEnvironment, org.default_content_view,
                            org.library, content_create.input[:content_id])
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
