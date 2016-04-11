module Actions
  module Katello
    module CapsuleContent
      class Sync < ::Actions::EntryAction
        def resource_locks
          :link
        end

        def humanized_name
          _("Synchronize capsule content")
        end

        def plan(capsule_content, options = {})
          action_subject(capsule_content.capsule)

          environment = options.fetch(:environment, nil)
          repository = options.fetch(:repository, nil)
          content_view = options.fetch(:content_view, nil)

          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          need_updates = repos_needing_updates(capsule_content, environment, content_view)
          need_updates.each do |repo|
            plan_action(Pulp::Repository::Refresh, repo, capsule_id: capsule_content.capsule.id)
          end

          repository_ids = get_repository_ids(capsule_content, environment, content_view, repository)
          unless repository_ids.blank?
            sequence do
              plan_action(ConfigureCapsule, capsule_content, environment, content_view)

              smart_proxy = SmartProxy.where(:content_host_id => capsule_content.consumer.id).first
              fail _("Smart Proxy not found for capsule.") unless smart_proxy
              concurrence do
                repository_ids.each do |repo_id|
                  plan_action(Pulp::Consumer::SyncCapsule,
                              capsule_id: smart_proxy.id,
                              repo_pulp_id: repo_id)
                end
              end
              plan_action(RemoveOrphans, :capsule_id => capsule_content.capsule.id)
            end
          end
        end

        def get_repository_ids(capsule, environment, content_view, repository)
          if environment
            repository_ids = capsule.repos_available_to_capsule(environment, content_view).map(&:pulp_id)
          elsif repository
            repository_ids = [repository.pulp_id]
            environment = repository.environment
          else
            repository_ids = capsule.repos_available_to_capsule.map(&:pulp_id)
          end

          if environment && !capsule.lifecycle_environments.include?(environment)
            fail _("Lifecycle environment '%{environment}' is not attached to this capsule.") % { :environment => environment.name }
          end

          repository_ids
        end

        def repos_needing_updates(capsule_content, environment, content_view)
          need_importer_update = repos_needing_importer_updates(capsule_content, environment, content_view)
          need_distributor_update = repos_needing_distributor_updates(capsule_content, environment, content_view)
          (need_distributor_update + need_importer_update).uniq
        end

        def repos_needing_distributor_updates(capsule, environment, content_view)
          repos = capsule.repos_available_to_capsule(environment, content_view)
          repos.select do |repo|
            repo_details = capsule.pulp_repo_facts(repo.pulp_id)
            next unless repo_details
            capsule_distributors = repo_details["distributors"]
            !(repo.distributors_match?(capsule_distributors))
          end
        end

        def repos_needing_importer_updates(capsule, environment, content_view)
          repos = capsule.repos_available_to_capsule(environment, content_view)
          repos.select do |repo|
            repo_details = capsule.pulp_repo_facts(repo.pulp_id)
            next unless repo_details
            capsule_importer = repo_details["importers"][0]["config"]
            !(repo.importer_matches?(capsule_importer))
          end
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
