module Katello
  module Pulp
    class Repository
      class File < ::Katello::Pulp::Repository
        def generate_master_importer
          config = { feed: root.url }
          importer_class.new(config.merge(master_importer_connection_options))
        end

        def generate_mirror_importer
          config = {
            feed: external_url
          }
          importer_class.new(config.merge(mirror_importer_connection_options))
        end

        def generate_distributors
          [Runcible::Models::IsoDistributor.new(repo.relative_path, repo.unprotected, true, auto_publish: true)]
        end

        def partial_repo_path
          "/pulp/isos/#{repo.relative_path}/"
        end

        def importer_class
          Runcible::Models::IsoImporter
        end
      end
    end
  end
end
