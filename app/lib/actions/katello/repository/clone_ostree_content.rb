module Actions
  module Katello
    module Repository
      class CloneOstreeContent < Actions::Base
        def plan(_source_repo, target_repo)
          sequence do
            plan_action(Katello::Repository::MetadataGenerate, target_repo)
            plan_action(ElasticSearch::Repository::IndexContent, id: target_repo.id)
          end
        end
      end
    end
  end
end
