module Actions
  module Katello
    module Repository
      class Clear < Actions::Base
        def plan(repo)
          [Pulp::Repository::RemoveRpm,
           Pulp::Repository::RemoveErrata,
           Pulp::Repository::RemovePackageGroup,
           Pulp::Repository::RemoveDistribution,
           Pulp::Repository::RemoveYumMetadataFile,
           Pulp::Repository::RemoveModuleDefault,
           Pulp::Repository::RemoveModuleStream,
           Pulp::Repository::RemoveFile,
           Pulp::Repository::RemovePuppetModule,
           Pulp::Repository::RemoveDockerManifest,
           Pulp::Repository::RemoveDockerManifestList,
           Pulp::Repository::RemoveDockerTag,
           Pulp::Repository::RemoveDockerBlob].each do |action_class|
            plan_action(action_class, pulp_id: repo.pulp_id)
          end
        end
      end
    end
  end
end
