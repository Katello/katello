module Actions
  module Pulp3
    module Orchestration
      module Repository
        class Sync < Pulp3::Abstract
          include Actions::Helpers::OutputPropagator
          def plan(repository, smart_proxy, **options)
            sequence do
              plan_action(Actions::Pulp3::Repository::RefreshRemote, repository, smart_proxy)
              action_output = plan_action(Actions::Pulp3::Repository::Sync, repository, smart_proxy, **options).output

              force_fetch_version = true if options[:optimize] == false
              version_output = plan_action(Pulp3::Repository::SaveVersion, repository, tasks: action_output[:pulp_tasks], :force_fetch_version => force_fetch_version).output

              #force contents_changed to true if we're doing a 'force' sync
              if options[:optimize] == false
                contents_changed = true
              else
                contents_changed = version_output[:contents_changed]
              end
              plan_action(Pulp3::Orchestration::Repository::GenerateMetadata, repository, smart_proxy, :contents_changed => contents_changed, :skip_publication_creation => version_output[:publication_provided])
              plan_self(:subaction_output => version_output)
            end
          end
        end
      end
    end
  end
end
