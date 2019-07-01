require 'pulp_file_client'
require 'pulp_ansible_client'

module Katello
  module Pulp3
    class Repository
      class AnsibleCollection < ::Katello::Pulp3::Repository
        def create_content_remote
          remote_collection_data = PulpAnsibleClient::CollectionRemote.new(remote_options)
          response = pulp3_api.remotes_ansible_collection_create(remote_collection_data)
          response._href
        end

        def remote_options
          if root.url.blank?
            super
          else
            common_remote_options.merge(url: root.url, whitelist: root.ansible_collection_whitelist || "testing.ansible_testing_content")
          end
        end

        def remote_partial_update
          pulp3_api.remotes_ansible_collection_partial_update(repo.remote_href, remote_options)
        end

        def delete_remote(href = repo.remote_href)
          pulp3_api.remotes_ansible_collection_delete(href) if href
        end

        def list_remotes(args)
          pulp3_api.remotes_ansible_collection_list(args).results
        end

        def sync
          [pulp3_api.remotes_ansible_collection_sync(repo.remote_href, repository: repository_reference.repository_href)]
        end

        def create_distribution(path)
          distribution_data = PulpAnsibleClient::AnsibleDistribution.new(
              base_path: path,
              repository_version: repo.version_href,
              name: "#{backend_object_name}")
          pulp3_api.distributions_ansible_ansible_create(distribution_data)
        end

        def delete_distribution(href)
          pulp3_api.distributions_ansible_ansible_delete(href)
        end

        def lookup_distributions(args)
          pulp3_api.distributions_ansible_ansible_list(args).results
        end

        def update_distribution(path)
          distribution_reference = distribution_reference(path)
          if distribution_reference
            distribution_data = PulpAnsibleClient::AnsibleDistribution.new(
                base_path: path,
                repository_version: repo.version_href,
                name: "#{backend_object_name}")
            pulp3_api.distributions_ansible_ansible_partial_update(distribution_reference.href, distribution_data)
          end
        end

        def get_distribution(href)
          pulp3_api.distributions_ansible_ansible_read(href)
        rescue PulpAnsibleClient::ApiError => e
          raise e if e.code != 404
          nil
        end
      end
    end
  end
end
