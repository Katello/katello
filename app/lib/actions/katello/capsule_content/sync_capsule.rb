module Actions
  module Katello
    module CapsuleContent
      class SyncCapsule < ::Actions::EntryAction
        include Actions::Katello::PulpSelector
        def available_repositories(smart_proxy, environment, content_view, repository)
          smart_proxy_service = ::Katello::Pulp::SmartProxyRepository.new(smart_proxy)
          repository_ids = smart_proxy_service.get_repository_ids(environment, content_view, repository)
          ::Katello::Repository.where(pulp_id: repository_ids) + ::Katello::ContentViewPuppetEnvironment.where(pulp_id: repository_ids)
        end

        # rubocop:disable MethodLength
        def plan(smart_proxy, options = {})
          action_subject(smart_proxy)
          environment_id = options.fetch(:environment_id, nil)
          environment = ::Katello::KTEnvironment.find(environment_id) if environment_id
          content_view_id = options.fetch(:content_view_id, nil)
          content_view = ::Katello::ContentView.find(content_view_id) if content_view_id
          repository_id = options.fetch(:repository_id, nil)
          repository = ::Katello::Repository.find(repository_id) if repository_id
          skip_metadata_check = options.fetch(:skip_metadata_check, false)

          concurrence do
            available_repositories(smart_proxy, environment, content_view, repository).each do |repo|
              plan_pulp_action([Actions::Pulp::Orchestration::Repository::SmartProxySync,
                                Actions::Pulp3::CapsuleContent::Sync],
                                 repo, smart_proxy,
                                 content_view: content_view,
                                 environment: environment,
                                 skip_metadata_check: skip_metadata_check)

              if repo.is_a?(::Katello::Repository) &&
                repo.distribution_bootable? &&
                repo.download_policy == ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND
                plan_action(Katello::Repository::FetchPxeFiles,
                            id: repository.id,
                            capsule_id: smart_proxy_service.smart_proxy.id)
              end
            end
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
