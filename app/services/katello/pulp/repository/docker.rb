module Katello
  module Pulp
    class Repository
      class Docker < ::Katello::Pulp::Repository
        REPOSITORY_TYPE = 'docker'.freeze

        def unit_type_id(uploads = [])
          uploads.pluck('digest').any? ? 'docker_tag' : super
        end

        def unit_keys(uploads)
          uploads.map do |upload|
            upload.except('id')
          end
        end

        def generate_primary_importer
          config = {
            feed: root.url,
            upstream_name: root.docker_upstream_name,
            tags: root.include_tags,
            enable_v1: false
          }
          importer_class.new(config.merge(primary_importer_connection_options))
        end

        def generate_distributors
          [Runcible::Models::DockerDistributor.new(:protected => !root.unprotected,
                                                  :id => repo.pulp_id,
                                                  :auto_publish => true,
                                                  :repo_registry_id => repo.container_repository_name)]
        end

        def distributors_to_publish(_options)
          {Runcible::Models::DockerDistributor => {}}
        end

        def importer_class
          Runcible::Models::DockerImporter
        end

        def copy_contents(destination_repo, options = {})
          if options[:filters]
            clause_gen = ::Katello::Util::DockerManifestClauseGenerator.new(@repo, options[:filters])
            clause_gen.generate
            criteria = {filters: {:unit => clause_gen.copy_clause } }
          end

          @smart_proxy.pulp_api.extensions.docker_tag.copy(
            @repo.pulp_id,
            destination_repo.pulp_id,
            criteria || {})
        end
      end
    end
  end
end
