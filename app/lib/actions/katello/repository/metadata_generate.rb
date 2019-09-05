module Actions
  module Katello
    module Repository
      class MetadataGenerate < Actions::Base
        include Actions::Katello::PulpSelector

        def plan(repository, options = {})
          dependency = options.fetch(:dependency, nil)
          force = options.fetch(:force, false)
          repository_creation = options.fetch(:repository_creation, false)
          source_repository = options.fetch(:source_repository, nil)
          source_repository ||= repository.target_repository if repository.link?
          smart_proxy_id = options.fetch(:capsule_id, SmartProxy.pulp_master.id)
          if repository_creation
            matching_content = false
          else
            matching_content = options.fetch(:matching_content, false)
          end

          plan_pulp_action([Pulp::Repository::DistributorPublish, Pulp3::Orchestration::Repository::GenerateMetadata],
                        repository, SmartProxy.find(smart_proxy_id),
                        :force => force,
                        :source_repository => source_repository,
                        :matching_content => matching_content,
                        :dependency => dependency,
                        :repository_creation => repository_creation)
        end
      end
    end
  end
end
