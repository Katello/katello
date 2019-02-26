module Actions
  module Katello
    module Repository
      class MetadataGenerate < Actions::Base
        def plan(repository, options = {})
          dependency = options.fetch(:dependency, nil)
          force = options.fetch(:force, false)
          source_repository = options.fetch(:source_repository, nil)
          source_repository ||= repository.target_repository if repository.link?
          plan_action(Pulp::Repository::DistributorPublish, repository, SmartProxy.pulp_master,
                        :force => force,
                        :matching_content => options[:matching_content],
                        :source_repository => source_repository,
                        :dependency => dependency)
        end
      end
    end
  end
end
