module Actions
  module Katello
    module Repository
      class UpdateMetadataSync < Actions::Base
        def plan(repository)
          sequence do
            plan_action(Katello::Repository::MetadataGenerate, repository)
            concurrence do
              ::SmartProxy.with_repo(repository).each do |capsule|
                next if capsule.pulp_master?
                plan_action(Katello::CapsuleContent::Sync, capsule, repository_id: repository.id)
              end
            end
          end
        end
      end
    end
  end
end
