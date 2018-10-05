module Katello
  module Pulp
    class Repository
      class Docker < ::Katello::Pulp::Repository
        def generate_master_importer
          config = {
            feed: root.url,
            upstream_name: root.docker_upstream_name,
            tags: root.docker_tags_whitelist,
            enable_v1: false
          }
          importer_class.new(config.merge(master_importer_connection_options))
        end

        def generate_mirror_importer
          pulp_uri = URI.parse(SmartProxy.pulp_master.pulp_url)
          config = {
            feed: "https://#{pulp_uri.host.downcase}:#{Setting['pulp_docker_registry_port']}",
            upstream_name: repo.container_repository_name,
            enable_v1: false
          }
          importer_class.new(config.merge(mirror_importer_connection_options))
        end

        def generate_distributors
          [Runcible::Models::DockerDistributor.new(:protected => !root.unprotected,
                                                  :id => repo.pulp_id,
                                                  :auto_publish => true,
                                                  :repo_registry_id => repo.container_repository_name)]
        end

        def external_url(_force_https = false)
          pulp_uri = URI.parse(SmartProxy.pulp_master.pulp_url)
          "#{pulp_uri.host.downcase}:#{Setting['pulp_docker_registry_port']}/#{repo.container_repository_name}"
        end

        def importer_class
          Runcible::Models::DockerImporter
        end
      end
    end
  end
end
