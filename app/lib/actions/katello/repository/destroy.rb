module Actions
  module Katello
    module Repository
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        # options:
        #   skip_environment_update - defaults to false. skips updating the CP environment
        #   planned_destroy - default to false.  destroy the AR object in plan phase instead of finalize
        def plan(repository, options = {})
          planned_destroy = options.fetch(:planned_destroy, false)

          skip_environment_update = options.fetch(:skip_environment_update, false) ||
              options.fetch(:organization_destroy, false)
          action_subject(repository)

          if !planned_destroy && !repository.destroyable?
            # The repository is going to be deleted in finalize, but it cannot be deleted.
            # Stop now and inform the user.
            fail repository.errors.messages.values.join("\n")
          end

          plan_action(ContentViewPuppetModule::Destroy, repository) if repository.puppet?
          plan_action(Pulp::Repository::Destroy, repository_id: repository.id)
          sequence do
            delete_record(repository) if planned_destroy
            if repository.redhat?
              handle_redhat_content(repository) unless skip_environment_update
            else
              handle_custom_content(repository) unless skip_environment_update
            end
          end

          plan_self(:user_id => ::User.current.id, :planned_destroy => planned_destroy)
        end

        def finalize
          unless input[:planned_destroy]
            repository = ::Katello::Repository.find(input[:repository][:id])
            delete_record(repository)
          end
        end

        def handle_custom_content(repository)
          #if this is the last instance of a custom repo, destroy the content
          if repository.root.repositories.where.not(id: repository.id).empty?
            plan_action(::Actions::Katello::Product::ContentDestroy, repository.root)
          end
        end

        def handle_redhat_content(repository)
          if repository.content_view.content_view_environment(repository.environment)
            plan_action(ContentView::UpdateEnvironment, repository.content_view, repository.environment)
          end
        end

        def delete_record(repository)
          repository.destroy!
          repository.root.destroy! if repository.root.repositories.empty?
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
