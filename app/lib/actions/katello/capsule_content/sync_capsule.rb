module Actions
  module Katello
    module CapsuleContent
      class SyncCapsule < ::Actions::EntryAction
        include Actions::Katello::PulpSelector

        # rubocop:disable MethodLength
        def plan(smart_proxy, options = {})
          action_subject(smart_proxy)
          environment = options[:environment]
          content_view = options[:content_view]
          repository = options[:repository]
          skip_metadata_check = options.fetch(:skip_metadata_check, false)

          smart_proxy_helper = ::Katello::SmartProxyHelper.new(smart_proxy)
          concurrence do
            smart_proxy_helper.repos_available_to_capsule(environment, content_view, repository).each do |repo|
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
