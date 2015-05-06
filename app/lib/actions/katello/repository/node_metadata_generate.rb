module Actions
  module Katello
    module Repository
      class NodeMetadataGenerate < Actions::Base
        def plan(repo)
          return unless repo.node_syncable?
          plan_action(Pulp::Repository::DistributorPublish,
                      pulp_id: repo.pulp_id,
                      distributor_type_id: Runcible::Models::NodesHttpDistributor.type_id)
        end
      end
    end
  end
end
