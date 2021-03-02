module Actions
  module Katello
    module Repository
      class Destroy < Actions::EntryAction
        include Actions::Katello::PulpSelector
        middleware.use ::Actions::Middleware::RemoteAction

        # options:
        #   skip_environment_update - defaults to false. skips updating the CP environment
        #   destroy_content - can be disabled to skip Candlepin remove_content
        def plan(repository, options = {})
          skip_environment_update = options.fetch(:skip_environment_update, false) ||
              options.fetch(:organization_destroy, false)
          destroy_content = options.fetch(:destroy_content, true)
          action_subject(repository)

          unless repository.destroyable?
            # The repository is going to be deleted in finalize, but it cannot be deleted.
            # Stop now and inform the user.
            fail repository.errors.messages.values.join("\n")
          end

          plan_pulp_action([Actions::Pulp::Orchestration::Repository::Delete,
                            Actions::Pulp3::Orchestration::Repository::Delete],
                           repository,
                           SmartProxy.pulp_primary)

          plan_self(:user_id => ::User.current.id)
          sequence do
            if repository.redhat?
              handle_redhat_content(repository) unless skip_environment_update
            else
              if destroy_content && !skip_environment_update
                handle_custom_content(repository)
              end
            end
          end
        end

        def finalize
          repository = ::Katello::Repository.find(input[:repository][:id])
          docker_cleanup = repository.content_type == ::Katello::Repository::DOCKER_TYPE
          delete_record(repository, {docker_cleanup: docker_cleanup})
        end

        def handle_custom_content(repository)
          #if this is the last instance of a custom repo, destroy the content
          if repository.root.repositories.where.not(id: repository.id).empty?
            plan_action(::Actions::Katello::Product::ContentDestroy, repository.root)
          end
        end

        def handle_redhat_content(repository)
          if repository.content_view.content_view_environment(repository.environment)
            plan_action(Candlepin::Environment::SetContent, repository.content_view, repository.environment, repository.content_view.content_view_environment(repository.environment))
          end
        end

        def delete_record(repository, options = {})
          ::Katello::SyncPlan.remove_disabled_product(repository) if repository.redhat?
          repository.destroy!
          repository.root.destroy! if repository.root.repositories.empty?
          ::Katello::DockerMetaTag.cleanup_tags if options[:docker_cleanup]
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
