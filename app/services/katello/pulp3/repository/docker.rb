require 'pulp_docker_client'

module Katello
  module Pulp3
    class Repository
      class Docker < ::Katello::Pulp3::Repository
        def self.api_client(smart_proxy)
          PulpDockerClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpDockerClient::Configuration))
        end

        def api_exception_class
          PulpDockerClient::ApiError
        end

        def client_class
          PulpDockerClient
        end

        def remote_class
          PulpDockerClient::DockerRemote
        end

        def remotes_api
          PulpDockerClient::RemotesDockerApi.new(api_client)
        end

        def distribution_class
          PulpDockerClient::DockerDistribution
        end

        def distributions_api
          PulpDockerClient::DistributionsDockerApi.new(api_client)
        end

        def remote_options
          options = {url: root.url, upstream_name: root.docker_upstream_name}
          if root.docker_tags_whitelist && root.docker_tags_whitelist.any?
            options[:whitelist_tags] = root.docker_tags_whitelist.join(",")
          else
            options[:whitelist_tags] = nil
          end
          common_remote_options.merge(options)
        end

        def mirror_remote_options
          docker_options = {
            url: "https://#{SmartProxy.pulp_master.pulp3_host!.downcase}",
            upstream_name: repo.container_repository_name
          }
          common_mirror_remote_options.merge(docker_options)
        end

        def distribution_options(path)
          {
            base_path: path,
            repository_version: repo.version_href,
            name: "#{backend_object_name}"
          }
        end
      end
    end
  end
end
