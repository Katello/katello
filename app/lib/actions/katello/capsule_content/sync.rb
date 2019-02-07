module Actions
  module Katello
    module CapsuleContent
      class Sync < ::Actions::EntryAction
        def resource_locks
          :link
        end

        input_format do
          param :name
        end

        def humanized_name
          _("Synchronize smart proxy")
        end

        def humanized_input
          ["'#{input['smart_proxy']['name']}'"] + super
        end

        # rubocop:disable MethodLength
        def plan(smart_proxy, options = {})
          action_subject(smart_proxy)
          smart_proxy_service = ::Katello::Pulp::SmartProxyRepository.new(smart_proxy)
          smart_proxy.ping_pulp
          smart_proxy.verify_ueber_certs

          environment_id = options.fetch(:environment_id, nil)
          environment = ::Katello::KTEnvironment.find(environment_id) if environment_id
          repository_id = options.fetch(:repository_id, nil)
          repository = ::Katello::Repository.find(repository_id) if repository_id
          content_view_id = options.fetch(:content_view_id, nil)
          content_view = ::Katello::ContentView.find(content_view_id) if content_view_id
          skip_metadata_check = options.fetch(:skip_metadata_check, false)

          fail _("Action not allowed for the default smart proxy.") if smart_proxy.pulp_master?

          affected_repos = affected_repositories(smart_proxy_service, environment, content_view, repository)
          need_updates = repos_needing_updates(smart_proxy, affected_repos)
          repository_ids = get_repository_ids(smart_proxy_service, environment, content_view, repository)

          # Create a list of non-puppet repos to sync first, and then sync puppet repos last.
          # Puppet modules may refer to non-puppet content in the same CV, and thus need to publish last.
          puppet_repository_ids = []
          non_puppet_repository_ids = []
          repository_ids.each do |repo_id|
            repo = ::Katello::Repository.find_by(pulp_id: repo_id) || ::Katello::ContentViewPuppetEnvironment.find_by(pulp_id: repo_id)
            repo.content_type == 'puppet' ? puppet_repository_ids << repo_id : non_puppet_repository_ids << repo_id
          end

          unless repository_ids.blank?
            sequence do
              need_updates.each do |repo|
                plan_action(Pulp::Repository::Refresh, repo, capsule_id: smart_proxy_service.smart_proxy.id)
              end
              plan_action(ConfigureCapsule, smart_proxy_service.smart_proxy, environment, content_view, repository)
              sync_repos_to_capsule(smart_proxy_service, non_puppet_repository_ids, skip_metadata_check) unless non_puppet_repository_ids.blank?
              sync_repos_to_capsule(smart_proxy_service, puppet_repository_ids, skip_metadata_check) unless puppet_repository_ids.blank?
            end
          end
        end

        def sync_repos_to_capsule(smart_proxy_service, repository_ids, skip_metadata_check)
          concurrence do
            repository_ids.each do |repo_id|
              sequence do
                repo = ::Katello::Repository.find_by(pulp_id: repo_id) ||
                        ::Katello::ContentViewPuppetEnvironment.find_by(pulp_id: repo_id)
                if repo && ['yum', 'puppet'].exclude?(repo.content_type)
                  # we unassociate units in non-yum/puppet repos in order to avoid version conflicts
                  # during publish. (i.e. two versions of a unit in the same repo)
                  plan_action(Pulp::Consumer::UnassociateUnits,
                              capsule_id: smart_proxy_service.smart_proxy.id,
                              repo_pulp_id: repo_id)
                end
                pulp_options = { remove_missing: repo && ["deb", "puppet", "yum"].include?(repo.content_type) }
                pulp_options[:force_full] = true if skip_metadata_check && repo.content_type == "yum"
                plan_action(Pulp::Consumer::SyncCapsule,
                            capsule_id: smart_proxy_service.smart_proxy.id,
                            repo_pulp_id: repo_id,
                            sync_options: pulp_options)
                if skip_metadata_check
                  plan_action(Katello::Repository::MetadataGenerate,
                              repo,
                              capsule_id: smart_proxy_service.smart_proxy.id,
                              force: true)
                end
                if repo.is_a?(::Katello::Repository) &&
                   repo.distribution_bootable? &&
                   repo.download_policy == ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND
                  plan_action(Katello::Repository::FetchPxeFiles,
                              id: repo.id,
                              capsule_id: smart_proxy_service.smart_proxy.id)
                end
              end
            end
          end
        end

        def get_repository_ids(smart_proxy_service, environment, content_view, repository)
          if environment
            repository_ids = smart_proxy_service.repos_available_to_capsule(environment, content_view).map(&:pulp_id)
          elsif repository
            repository_ids = [repository.pulp_id]
            environment = repository.environment
          else
            repository_ids = smart_proxy_service.repos_available_to_capsule.map(&:pulp_id)
          end

          if environment && !smart_proxy_service.smart_proxy.lifecycle_environments.include?(environment)
            fail _("Lifecycle environment '%{environment}' is not attached to this capsule.") % { :environment => environment.name }
          end

          repository_ids
        end

        def affected_repositories(smart_proxy_service, environment, content_view, repository)
          if repository
            [repository]
          else
            smart_proxy_service.repos_available_to_capsule(environment, content_view)
          end
        end

        def repos_needing_updates(smart_proxy, repos)
          need_importer_update = ::Katello::Repository.needs_importer_updates(repos, smart_proxy)
          need_distributor_update = ::Katello::Repository.needs_distributor_updates(repos, smart_proxy)
          (need_distributor_update + need_importer_update).uniq
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
