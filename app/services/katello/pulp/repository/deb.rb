module Katello
  module Pulp
    class Repository
      class Deb < ::Katello::Pulp::Repository
        REPOSITORY_TYPE = 'deb'.freeze

        def generate_primary_importer
          config = {
            feed: root.url,
            remove_missing: root.mirror_on_sync?,
            releases: root.deb_releases,
            components: root.deb_components,
            architectures: root.deb_architectures,
            gpg_keys: root&.gpg_key&.content,
            require_signature: root.gpg_key.present?
          }
          importer_class.new(config.merge(primary_importer_connection_options))
        end

        def generate_mirror_importer
          config = {
            feed: external_url,
            remove_missing: true,
            releases: root.deb_releases&.split&.join(','),
            components: root.deb_components&.split&.join(','),
            architectures: root.deb_architectures&.split&.join(','),
            gpg_keys: root&.gpg_key&.content,
            require_signature: root.gpg_key.present?
          }
          importer_class.new(config.merge(mirror_importer_connection_options))
        end

        def generate_distributors
          [Runcible::Models::DebDistributor.new(repo.relative_path, root.unprotected, true,
                                                id: repo.pulp_id,
                                                auto_publish: true)]
        end

        def distributors_to_publish(_options)
          {Runcible::Models::DebDistributor => {}}
        end

        def partial_repo_path
          "/pulp/deb/#{repo.relative_path}/"
        end

        def importer_class
          Runcible::Models::DebImporter
        end

        def copy_contents(destination_repo, _options = {})
          [
            @smart_proxy.pulp_api.extensions.deb.copy(@repo.pulp_id, destination_repo.pulp_id, fields: ::Katello::Pulp::Deb::PULP_SELECT_FIELDS),
            @smart_proxy.pulp_api.extensions.deb_release.copy(@repo.pulp_id, destination_repo.pulp_id, {}),
            @smart_proxy.pulp_api.extensions.deb_component.copy(@repo.pulp_id, destination_repo.pulp_id, {})
          ]
        end
      end
    end
  end
end
