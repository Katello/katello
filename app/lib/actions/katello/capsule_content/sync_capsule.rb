module Actions
  module Katello
    module CapsuleContent
      class SyncCapsule < ::Actions::EntryAction
        # rubocop:disable Metrics/MethodLength
        execution_plan_hooks.use :update_content_counts, :on => :success
        def plan(smart_proxy, options = {})
          plan_self(:smart_proxy_id => smart_proxy.id)
          action_subject(smart_proxy)
          environment = options[:environment]
          content_view = options[:content_view]
          repository = options[:repository]
          skip_metadata_check = options.fetch(:skip_metadata_check, false)
          sequence do
            repos = repos_to_sync(smart_proxy, environment, content_view, repository, skip_metadata_check)
            return nil if repos.empty?

            if environment.nil? && content_view.nil? && repository.nil?
              options[:repository_ids_list] = repos.pluck(:id)
            end
            if smart_proxy.has_feature?(SmartProxy::PULP3_FEATURE)
              plan_action(Actions::Pulp3::Orchestration::Repository::RefreshRepos, smart_proxy, **options)
            end

            repos.in_groups_of(Setting[:foreman_proxy_content_batch_size], false) do |repo_batch|
              concurrence do
                repo_batch.each do |repo|
                  if smart_proxy.pulp3_support?(repo)
                    plan_action(Actions::Pulp3::CapsuleContent::Sync,
                      repo, smart_proxy,
                      skip_metadata_check: skip_metadata_check)
                  end
                end
              end

              concurrence do
                repo_batch.each do |repo|
                  if repo.is_a?(::Katello::Repository) &&
                      repo.distribution_bootable? &&
                      repo.download_policy == ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
                    plan_action(Katello::Repository::FetchPxeFiles,
                                id: repo.id,
                                capsule_id: smart_proxy.id)
                  end
                end
              end
            end
          end
        end
        # rubocop:enable Metrics/MethodLength

        def repos_to_sync(smart_proxy, environment, content_view, repository, skip_metatadata_check = false)
          smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
          smart_proxy_helper.lifecycle_environment_check(environment, repository)
          if repository
            if skip_metatadata_check || !repository.smart_proxy_sync_histories.where(:smart_proxy_id => smart_proxy).any? { |sph| !sph.finished_at.nil? }
              [repository]
            end
          else
            repositories = smart_proxy_helper.repositories_available_to_capsule(environment, content_view).by_rpm_count
            repositories_to_skip = []
            if skip_metatadata_check
              smart_proxy_helper.clear_smart_proxy_sync_histories repositories
            else
              repositories_to_skip = ::Katello::Repository.synced_on_capsule smart_proxy
            end
            repositories - repositories_to_skip
          end
        end

        def update_content_counts(_execution_plan)
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          ::ForemanTasks.async_task(::Actions::Katello::CapsuleContent::UpdateContentCounts, smart_proxy)
        end

        def resource_locks
          :link
        end

        def run
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          smart_proxy.sync_container_gateway
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
