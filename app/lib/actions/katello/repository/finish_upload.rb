module Actions
  module Katello
    module Repository
      class FinishUpload < Actions::Base
        def plan(repository, dependency = nil)
          unless repository.puppet?
            plan_action(Katello::Repository::MetadataGenerate, repository, nil, dependency)
          end

          recent_range = 5.minutes.ago.iso8601
          plan_action(Katello::Repository::FilteredIndexContent,
                      id: repository.id,
                      filter: {:association => {:created => {"$gt" => recent_range}}},
                      dependency: dependency)
        end
      end
    end
  end
end
