require 'pulp_docker_client'

module Katello
  module Pulp3
    class Repository
      class Docker < ::Katello::Pulp3::Repository
        def self.api_client(smart_proxy)
          PulpDockerClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpDockerClient::Configuration))
        end

        def self.api_exception_class
          PulpDockerClient::ApiError
        end

        def client_class
          PulpDockerClient
        end

        def remote_class
          PulpDockerClient::DockerDockerRemote
        end

        def self.remotes_api(smart_proxy)
          PulpDockerClient::RemotesDockerApi.new(api_client(smart_proxy))
        end

        def distribution_class
          PulpDockerClient::DockerDockerDistribution
        end

        def self.distributions_api(smart_proxy)
          PulpDockerClient::DistributionsDockerApi.new(api_client(smart_proxy))
        end

        def recursive_manage_class
          PulpDockerClient::RecursiveManage
        end

        def recursive_add_api
          PulpDockerClient::DockerRecursiveAddApi.new(api_client)
        end

        def remote_options
          options = {url: root.url, upstream_name: root.docker_upstream_name}
          if root.docker_tags_whitelist && root.docker_tags_whitelist.any?
            options[:whitelist_tags] = root.docker_tags_whitelist
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

        def copy_units_recursively(unit_hrefs, clear_repo = false)
          tasks = []
          if clear_repo
            tasks << create_version(:remove_content_units => ["*"])
          end
          tasks << recursive_add_api.create(recursive_manage_class.new(repository: repository_reference.repository_href,
                                                                       content_units: unit_hrefs))
          tasks
        end

        def copy_content_for_source(source_repository, options = {})
          filters = ContentViewDockerFilter.where(:id => options[:filter_ids])
          whitelist_ids = []
          blacklist_ids = []
          filters.each do |filter|
            if filter.inclusion
              whitelist_ids += filter.content_unit_pulp_ids(source_repository)
            else
              blacklist_ids += filter.content_unit_pulp_ids(source_repository)
            end
          end

          if whitelist_ids.empty?
            copy_units_recursively(source_repository.docker_tags.pluck(:pulp_id).sort - blacklist_ids, true)
          else
            copy_units_recursively(whitelist_ids - blacklist_ids, true)
          end
        end
      end
    end
  end
end
