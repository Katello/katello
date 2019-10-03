module Katello
  module Pulp
    class Repository
      class File < ::Katello::Pulp::Repository
        REPOSITORY_TYPE = 'iso'.freeze

        def unit_keys(uploads)
          uploads.map do |upload|
            upload.except('id', 'content_unit_id')
          end
        end

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
          yum_dist_id = repo.pulp_id
          options = {
            id: yum_dist_id,
            auto_publish: true
          }
          [Runcible::Models::IsoDistributor.new(repo.relative_path, repo.unprotected, true, options)]
        end

        def partial_repo_path
          "/pulp/isos/#{repo.relative_path}/"
        end

        def importer_class
          Runcible::Models::IsoImporter
        end

        def distributors_to_publish(_options)
          {Runcible::Models::IsoDistributor => {}}
        end

        def copy_contents(destination_repo, _options = {})
          @smart_proxy.pulp_api.extensions.file.copy(@repo.pulp_id, destination_repo.pulp_id, {})
        end
      end
    end
  end
end
