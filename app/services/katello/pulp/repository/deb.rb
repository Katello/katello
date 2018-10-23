module Katello
  module Pulp
    class Repository
      class Deb < ::Katello::Pulp::Repository
        def generate_master_importer
          config = {
            feed: root.url,
            remove_missing: root.mirror_on_sync?,
            releases: root.deb_releases,
            components: root.deb_components,
            architectures: root.deb_architectures
          }
          importer_class.new(config.merge(master_importer_connection_options))
        end

        def generate_mirror_importer
          config = {
            feed: external_url,
            remove_missing: true,
            releases: root.deb_releases,
            components: root.deb_components,
            architectures: root.deb_architectures
          }
          importer_class.new(config.merge(mirror_importer_connection_options))
        end

        def generate_distributors
          [Runcible::Models::DebDistributor.new(repo.relative_path, root.unprotected, true,
                                                id: repo.pulp_id,
                                                auto_publish: true)]
        end

        def partial_repo_path
          "/pulp/deb/#{repo.relative_path}/"
        end

        def importer_class
          Runcible::Models::DebImporter
        end
      end
    end
  end
end
