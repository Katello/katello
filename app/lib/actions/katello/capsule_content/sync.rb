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
          capsule_content.ping_pulp
          capsule_content.verify_ueber_certs
          action_subject(capsule_content.capsule)

          environment = options.fetch(:environment, nil)
          repository = options.fetch(:repository, nil)
          content_view = options.fetch(:content_view, nil)

          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          affected_repos = affected_repositories(capsule_content, environment, content_view, repository)
          need_updates = repos_needing_updates(capsule_content, affected_repos)
          repository_ids = get_repository_ids(capsule_content, environment, content_view, repository)
          unless repository_ids.blank?
            sequence do
              need_updates.each do |repo|
                plan_action(Pulp::Repository::Refresh, repo, capsule_id: capsule_content.capsule.id)
              end
              plan_action(ConfigureCapsule, capsule_content, environment, content_view, repository)
              sync_repos_to_capsule(capsule_content, repository_ids)
              plan_action(RemoveOrphans, :capsule_id => capsule_content.capsule.id)
            end
          end
        end

        def sync_repos_to_capsule(capsule_content, repository_ids)
          concurrence do
            repository_ids.each do |repo_id|
              sequence do
                repo = ::Katello::Repository.where(:pulp_id => repo_id).first ||
                       ::Katello::ContentViewPuppetEnvironment.where(:pulp_id => repo_id).first
                if repo && repo.content_type != "yum"
                  # we unassociate units in non-yum repos in order to avoid version conflicts
                  # during publish. (i.e. two versions of a puppet module in the same repo)
                  plan_action(Pulp::Consumer::UnassociateUnits,
                              capsule_id: capsule_content.capsule.id,
                              repo_pulp_id: repo_id)
                end

                plan_action(Pulp::Consumer::SyncCapsule,
                            capsule_id: capsule_content.capsule.id,
                            repo_pulp_id: repo_id)
              end
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

        def affected_repositories(capsule_content, environment, content_view, repository)
          if repository
            [repository]
          else
            capsule_content.repos_available_to_capsule(environment, content_view)
          end
        end

        def repos_needing_updates(capsule_content, repos)
          need_importer_update = ::Katello::Repository.needs_importer_updates(repos, capsule_content)
          need_distributor_update = ::Katello::Repository.needs_distributor_updates(repos, capsule_content)
          (need_distributor_update + need_importer_update).uniq
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
