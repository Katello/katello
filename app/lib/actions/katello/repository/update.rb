module Actions
  module Katello
    module Repository
      class Update < Actions::EntryAction
        include Actions::Katello::PulpSelector
        def plan(root, repo_params)
          repository = root.library_instance
          action_subject root.library_instance

          repo_params[:url] = nil if repo_params[:url] == ''
          update_cv_cert_protected = repo_params.key?(:unprotected) && (repo_params[:unprotected] != repository.unprotected)
          update_auto_enabled = repo_params.key?(:auto_enabled) && (repo_params[:auto_enabled] != root.auto_enabled)
          root.update!(repo_params)

          if root.download_policy == ::Runcible::Models::YumImporter::DOWNLOAD_BACKGROUND
            ::Foreman::Deprecation.api_deprecation_warning("Background download_policy will be removed in Katello 4.0.  Any background repositories will be converted to Immediate")
          end

          if root['content_type'] == 'puppet' || root['content_type'] == 'ostree'
            ::Foreman::Deprecation.api_deprecation_warning("Repository types of 'Puppet' and 'OSTree' will no longer be supported in Katello 4.0.")
          end

          if update_content?(repository)
            plan_action(Katello::Repository::ContentUpdate, repository,
                        update_auto_enabled: update_auto_enabled)
          end

          if root.pulp_update_needed?
            sequence do
              plan_pulp_action([::Actions::Pulp::Orchestration::Repository::Refresh,
                                ::Actions::Pulp3::Orchestration::Repository::Update],
                               repository,
                               SmartProxy.pulp_primary)
              plan_self(:repository_id => root.library_instance.id)
              if update_cv_cert_protected
                plan_optional_pulp_action([::Actions::Pulp3::Orchestration::Repository::TriggerUpdateRepoCertGuard], repository, ::SmartProxy.pulp_primary)
              end
            end
          end
        end

        def run
          repository = ::Katello::Repository.find(input[:repository_id])
          ForemanTasks.async_task(Katello::Repository::MetadataGenerate, repository)
        end

        private

        def update_content?(repository)
          repository.library_instance? && !repository.product.redhat?
        end
      end
    end
  end
end
