module Actions
  module Katello
    module Repository
      class MetadataGenerate < Actions::Base
        def plan(repository, options = {})
          source_repository = options.fetch(:source_repository, nil)
          source_repository ||= repository.target_repository if repository.link?
          smart_proxy = options.fetch(:smart_proxy, SmartProxy.pulp_primary)
          matching_content = options.fetch(:matching_content, false)
          force_publication = options.fetch(:force_publication, false)

          plan_action(Pulp3::Orchestration::Repository::GenerateMetadata,
                        repository, smart_proxy,
                        :force_publication => force_publication,
                        :source_repository => source_repository,
                        :matching_content => matching_content)
        end
      end
    end
  end
end
