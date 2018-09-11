module Actions
  module Katello
    module Repository
      class FinishUpload < Actions::Base
        def plan(repository, options = {})
          dependency = options.fetch(:dependency, nil)
          generate_metadata = options.fetch(:generate_metadata, true)
          plan_action(Katello::Repository::MetadataGenerate, repository, :dependency => dependency) if generate_metadata

          recent_range = 5.minutes.ago.utc.iso8601
          plan_action(Katello::Repository::FilteredIndexContent,
                      id: repository.id,
                      filter: {:association => {:created => {"$gt" => recent_range}}},
                      dependency: dependency)
        end
      end
    end
  end
end
