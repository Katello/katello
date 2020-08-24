module Actions
  module Katello
    module CapsuleContent
      class SyncCapsule < ::Actions::EntryAction
        include Actions::Katello::PulpSelector
        def plan(smart_proxy, options = {})
          action_subject(smart_proxy)
          environment = options[:environment]
          content_view = options[:content_view]
          repository = options[:repository]
          skip_metadata_check = options.fetch(:skip_metadata_check, false)

          sequence do
            repos = repos_to_sync(smart_proxy, environment, content_view, repository)

            repos.in_groups_of(Setting[:foreman_proxy_content_batch_size], false) do |repo_batch|
              concurrence do
                repo_batch.each do |repo|
                  plan_pulp_action([Actions::Pulp::Orchestration::Repository::SmartProxySync,
                                    Actions::Pulp3::CapsuleContent::Sync],
                                     repo, smart_proxy,
                                     skip_metadata_check: skip_metadata_check)

                  if repo.is_a?(::Katello::Repository) &&
                    repo.distribution_bootable? &&
                    repo.download_policy == ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND
                    plan_action(Katello::Repository::FetchPxeFiles,
                                id: repo.id,
                                capsule_id: smart_proxy.id)
                  end
                end
              end
            end
          end
        end

        def repos_to_sync(smart_proxy, environment, content_view, repository)
          smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
          smart_proxy_helper.lifecycle_environment_check(environment, repository)

          if repository
            [repository]
          else
            repositories = smart_proxy_helper.repositories_available_to_capsule(environment, content_view).by_rpm_count
            puppet_envs = smart_proxy_helper.puppet_environments_available_to_capsule(environment, content_view)
            repositories + puppet_envs
          end
        end

        def resource_locks
          :link
        end
      end
    end
  end
end
