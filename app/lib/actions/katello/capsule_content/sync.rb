module Actions
  module Katello
    module CapsuleContent
      class Sync < ::Actions::EntryAction
        def humanized_name
          _("Synchronize capsule content")
        end

        def plan(capsule_content, options = {})
          environment = options.fetch(:environment, nil)
          repository = options.fetch(:repository, nil)
          content_view = options.fetch(:content_view, nil)

          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          repository_ids = get_repository_ids(capsule_content, environment, content_view, repository)
          unless repository_ids.blank?
            sequence do
              plan_action(ConfigureCapsule, capsule_content)
              plan_action(Pulp::Consumer::SyncNode,
                          consumer_uuid: capsule_content.consumer_uuid,
                          repo_ids: repository_ids)
            end
          end
        end

        def get_repository_ids(capsule, environment, content_view, repository)
          if environment
            repository_ids = capsule.pulp_repos([environment], content_view).map(&:pulp_id)
          elsif repository
            repository_ids = [repository.pulp_id]
            environment = repository.environment
          else
            repository_ids = capsule.pulp_repos.map(&:pulp_id)
          end

          if environment && !capsule.lifecycle_environments.include?(environment)
            fail _("Lifecycle environment '%{environment}' is not attached to this capsule.") % { :environment => environment.name }
          end

          repository_ids
        end
      end
    end
  end
end
