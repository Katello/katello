module Actions
  module Katello
    module Repository
      class MetadataGenerate < Actions::Base
        def plan(repository, source_repository = nil, dependency = nil)
          distributors(repository, source_repository).each do |distributor|
            plan_action(Pulp::Repository::DistributorPublish,
                        pulp_id: repository.pulp_id,
                        distributor_type_id: distributor.type_id,
                        source_pulp_id: source_repository.try(:pulp_id),
                        dependency: dependency)
          end
        end

        def distributors(repository, clone)
          case repository.content_type
          when ::Katello::Repository::YUM_TYPE
            if clone
              [Runcible::Models::YumCloneDistributor]
            else
              [Runcible::Models::YumDistributor]
            end
          when ::Katello::Repository::PUPPET_TYPE
            if repository.is_a?(::Katello::ContentViewPuppetEnvironment) && !repository.puppet_environment.nil?
              [Runcible::Models::PuppetDistributor, Runcible::Models::PuppetInstallDistributor]
            else
              [Runcible::Models::PuppetDistributor]
            end
          when ::Katello::Repository::FILE_TYPE
            [Runcible::Models::IsoDistributor]
          when ::Katello::Repository::DOCKER_TYPE
            [Runcible::Models::DockerDistributor]
          when ::Katello::Repository::OSTREE_TYPE
            [Runcible::Models::OstreeDistributor]
          end
        end
      end
    end
  end
end
