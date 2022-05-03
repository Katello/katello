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
          smart_proxy = options.fetch(:smart_proxy, SmartProxy.pulp_primary)
          matching_content = options.fetch(:matching_content, false)
          deb_simple_publish_only = options.fetch(:deb_simple_publish_only, false)

          plan_pulp_action([Pulp::Repository::DistributorPublish, Pulp3::Orchestration::Repository::GenerateMetadata],
                        repository, smart_proxy,
                        :force => force,
                        :source_repository => source_repository,
                        :matching_content => matching_content,
                        :deb_simple_publish_only => deb_simple_publish_only,
                        :dependency => dependency)
        end
      end
    end
  end
end
