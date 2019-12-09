module Actions
  module Katello
    module Repository
      class MetadataGenerate < Actions::Base
        include Actions::Katello::PulpSelector

        def plan(repository, options = {})
          dependency = options.fetch(:dependency, nil)
          force = options.fetch(:force, false)
          source_repository = options.fetch(:source_repository, nil)
          source_repository ||= repository.target_repository if repository.link?
          smart_proxy = options.fetch(:smart_proxy, SmartProxy.pulp_master)
          matching_content = options.fetch(:matching_content, false)

          plan_pulp_action([Pulp::Repository::DistributorPublish, Pulp3::Orchestration::Repository::GenerateMetadata],
                        repository, smart_proxy,
                        :force => force,
                        :source_repository => source_repository,
                        :matching_content => matching_content,
                        :dependency => dependency)
        end
      end
    end
  end
end
