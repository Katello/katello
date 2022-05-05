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

        def regenerate_applicability
          smart_proxy.pulp_api.extensions.repository.regenerate_applicability_by_ids([repo.pulp_id], true)
        end

        def copy_contents(destination_repo, options = {})
          if options[:filters]
            deb_copy_clauses, deb_remove_clauses = generate_copy_clauses(options[:filters])
          end

          if deb_copy_clauses
            [
              @smart_proxy.pulp_api.extensions.deb.copy(@repo.pulp_id, destination_repo.pulp_id, deb_copy_clauses),
              @smart_proxy.pulp_api.extensions.deb_release.copy(@repo.pulp_id, destination_repo.pulp_id, {}),
              @smart_proxy.pulp_api.extensions.deb_component.copy(@repo.pulp_id, destination_repo.pulp_id, {})
            ]

          end

          if deb_remove_clauses
            @smart_proxy.pulp_api.extensions.repository.unassociate_units(destination_repo.pulp_id,
                                                                         type_ids: [::Katello::Pulp::Deb::CONTENT_TYPE],
                                                                          filters: {unit: deb_remove_clauses})
          end

          tasks
        end

        def generate_copy_clauses(filters)
          copy_clauses = {}
          remove_clauses = nil

          if filters
            clause_gen = ::Katello::Util::DebClauseGenerator.new(repo, filters)
            clause_gen.generate

            copy = clause_gen.copy_clause
            copy_clauses = {filters: {unit: copy }} if copy

            remove = clause_gen.remove_clause
            remove_clauses = {filters: {unit: remove}} if remove
          end

          copy_clauses&.merge!(fields: ::Katello::Pulp::Deb::PULP_SELECT_FIELDS)
          [copy_clauses, remove_clauses]
        end
      end
    end
  end
end
