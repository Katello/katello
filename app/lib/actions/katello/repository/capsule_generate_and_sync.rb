module Actions
  module Katello
    module Repository
      class CapsuleGenerateAndSync < Actions::Base
        def humanized_name
          _("Generate Capsule Metadata and Sync")
        end

        def plan(repo)
          if repo.node_syncable?
            plan_action(NodeMetadataGenerate, repo)

            concurrence do
              ::Katello::CapsuleContent.with_environment(repo.environment).each do |capsule_content|
                plan_action(Katello::CapsuleContent::Sync, capsule_content, repository: repo)
              end
            end
          end
        end
      end
    end
  end
end
