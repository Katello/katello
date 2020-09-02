module Katello
  module Pulp
    class Repository
      class Ostree < ::Katello::Pulp::Repository
        PULP_MIRROR_SYNC_DEPTH = -1

        def generate_primary_importer
          config = {
            feed: root.url,
            depth: root.compute_ostree_upstream_sync_depth
          }
          Runcible::Models::OstreeImporter.new(config.merge(primary_importer_connection_options))
        end

        def generate_mirror_importer
          config = {
            feed: external_url(true),
            depth: PULP_MIRROR_SYNC_DEPTH
          }
          Runcible::Models::OstreeImporter.new(config.merge(mirror_importer_connection_options))
        end

        def generate_distributors
          [Runcible::Models::OstreeDistributor.new(:id => repo.pulp_id,
                                                  :auto_publish => true,
                                                  :relative_path => repo.relative_path,
                                                  :depth => root.compute_ostree_upstream_sync_depth)]
        end

        def distributors_to_publish(_options)
          {Runcible::Models::OstreeDistributor => {}}
        end

        def partial_repo_path
          "/pulp/ostree/web/#{repo.relative_path}".sub('//', '/')
        end

        def importer_class
          Runcible::Models::OstreeImporter
        end

        def copy_contents(destination_repo, _options = {})
          @smart_proxy.pulp_api.extensions.ostree_branch.copy(@repo.pulp_id, destination_repo.pulp_id, {})
        end
      end
    end
  end
end
