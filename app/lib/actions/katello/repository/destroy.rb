module Actions
  module Katello
    module Repository
      class Destroy < Actions::EntryAction
        middleware.use ::Actions::Middleware::RemoteAction

        # options:
        #   skip_environment_update - defaults to false. skips updating the CP environment
        #   destroy_content - can be disabled to skip Candlepin remove_content
        def plan(repository, options = {})
          affected_cvv_ids = []
          skip_environment_update = options.fetch(:skip_environment_update, false) ||
              options.fetch(:organization_destroy, false)
          destroy_content = options.fetch(:destroy_content, true)
          remove_from_content_view_versions = options.fetch(:remove_from_content_view_versions, false)
          action_subject(repository)
          check_destroyable!(repository, remove_from_content_view_versions)
          remove_generated_content_views(repository)

          remove_versions(repository, repository.content_views.generated_for_library, affected_cvv_ids)

          plan_action(Actions::Pulp3::Orchestration::Repository::Delete,
                           repository,
                           SmartProxy.pulp_primary)

          remove_versions(repository, repository.content_views.generated_for_none, affected_cvv_ids) if remove_from_content_view_versions

          plan_self(:user_id => ::User.current.id, :affected_cvv_ids => affected_cvv_ids)
          sequence do
            if repository.redhat?
              handle_redhat_content(repository) unless skip_environment_update
            else
              if destroy_content && !skip_environment_update
                handle_custom_content(repository, remove_from_content_view_versions)
              end
            end
          end
        end

        def finalize
          repository = ::Katello::Repository.find_by(id: input[:repository][:id])
          if repository
            docker_cleanup = repository.content_type == ::Katello::Repository::DOCKER_TYPE
            delete_record(repository, {docker_cleanup: docker_cleanup})

            if (affected_cvv_ids = input[:affected_cvv_ids]).any?
              cvvs = ::Katello::ContentViewVersion.where(id: affected_cvv_ids)
              cvvs.each do |cvv|
                cvv.update_content_counts!
              end
            end
          end
        end

        def handle_custom_content(repository, remove_from_content_view_versions)
          #if this is the last instance of a custom repo, destroy the content
          if remove_from_content_view_versions || repository.root.repositories.where.not(id: repository.id).empty?
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

        def remove_generated_content_views(repository)
          # remove the content views generated for this repository (since we are deleting the repo)
          content_views = repository.content_views.generated_for_repository
          return if content_views.blank?
          plan_action(::Actions::BulkAction, ::Actions::Katello::ContentView::Remove,
                        content_views,
                        skip_repo_destroy: true,
                        destroy_content_view: true)
        end

        def remove_versions(repository, content_views, affected_cvv_ids)
          return if content_views.blank?

          interested_inverses = repository.
                                  library_instances_inverse.
                                  joins(:content_view_version => :content_view).
                                  merge(content_views)
          affected_cvv_ids.concat(interested_inverses.pluck(:content_view_version_id).uniq)
          plan_action(::Actions::BulkAction, ::Actions::Katello::Repository::Destroy, interested_inverses)
        end

        def check_destroyable!(repository, remove_from_content_view_versions)
          unless repository.destroyable?(remove_from_content_view_versions)
            # The repository is going to be deleted in finalize, but it cannot be deleted.
            # Stop now and inform the user.
            fail repository.errors.messages.values.join("\n")
          end
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
