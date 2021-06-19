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
            repos = repos_to_sync(smart_proxy, environment, content_view, repository, skip_metadata_check)

            repos.in_groups_of(Setting[:foreman_proxy_content_batch_size], false) do |repo_batch|
              concurrence do
                repo_batch.each do |repo|
                  plan_pulp_action([Actions::Pulp::Orchestration::Repository::SmartProxySync,
                                    Actions::Pulp3::CapsuleContent::Sync],
                                     repo, smart_proxy,
                                     skip_metadata_check: skip_metadata_check)
                end
              end

              concurrence do
                repo_batch.each do |repo|
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
          sync_container_gateway(smart_proxy)
        end

        def sync_container_gateway(smart_proxy)
          if smart_proxy.has_feature?(::SmartProxy::CONTAINER_GATEWAY_FEATURE)
            update_container_repo_list(smart_proxy)
            users = smart_proxy.container_gateway_users
            update_user_container_repo_mapping(smart_proxy, users) if users.any?
          end
        end

        def unauthenticated_container_repositories
          ::Katello::Repository.joins(:environment).where("#{::Katello::KTEnvironment.table_name}.registry_unauthenticated_pull" => true).select(:id).pluck(:id)
        end

        def update_container_repo_list(smart_proxy)
          # [{ repository: "repoA", auth_required: false }]
          repo_list = []
          ::Katello::SmartProxyHelper.new(smart_proxy).combined_repos_available_to_capsule.each do |repo|
            if repo.docker? && !repo.container_repository_name.nil?
              repo_list << { repository: repo.container_repository_name,
                             auth_required: !unauthenticated_container_repositories.include?(repo.id) }
            end
          end
          smart_proxy.update_container_repo_list(repo_list)
        end

        def update_user_container_repo_mapping(smart_proxy, users)
          # Example user-repo mapping:
          # { users:
          #   [
          #     'user a' => [{ repository: 'repo 1', auth_required: true }]
          #   ]
          # }

          user_repo_map = { users: [] }
          users.each do |user|
            inner_repo_list = []
            repositories = ::Katello::Repository.readable_docker_catalog_as(user)
            repositories.each do |repo|
              next if repo.container_repository_name.nil?
              inner_repo_list << { repository: repo.container_repository_name,
                                   auth_required: !unauthenticated_container_repositories.include?(repo.id) }
            end
            user_repo_map[:users] << { user.login => inner_repo_list }
          end
          smart_proxy.update_user_container_repo_mapping(user_repo_map)
        end

        def repos_to_sync(smart_proxy, environment, content_view, repository, skip_metatadata_check = false)
          smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
          smart_proxy_helper.lifecycle_environment_check(environment, repository)
          if repository
            if skip_metatadata_check || !repository.smart_proxy_sync_histories.where(:smart_proxy_id => smart_proxy).any? { |sph| !sph.finished_at.nil? }
              [repository]
            end
          else
            repositories = smart_proxy_helper.repositories_available_to_capsule(environment, content_view).by_rpm_count
            puppet_envs = smart_proxy_helper.puppet_environments_available_to_capsule(environment, content_view)
            repositories_to_skip = []
            if skip_metatadata_check
              smart_proxy_helper.clear_smart_proxy_sync_histories repositories
            else
              repositories_to_skip = ::Katello::Repository.synced_on_capsule smart_proxy
            end
            repositories - repositories_to_skip + puppet_envs
          end
        end

        def resource_locks
          :link
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
