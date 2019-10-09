require 'pulp_ansible_client'

module Katello
  module Pulp3
    class Repository
      class AnsibleCollection < ::Katello::Pulp3::Repository
        def self.api_client(smart_proxy)
          PulpAnsibleClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpAnsibleClient::Configuration))
        end

        def client_class
          PulpAnsibleClient
        end

        def self.api_exception_class
          PulpAnsibleClient::ApiError
        end

        def remote_class
          PulpAnsibleClient::CollectionRemote
        end

        def self.remotes_api(smart_proxy)
          PulpAnsibleClient::RemotesCollectionApi.new(api_client(smart_proxy))
        end

        def distribution_class
          PulpAnsibleClient::AnsibleDistribution
        end

        def self.distributions_api(smart_proxy)
          PulpAnsibleClient::DistributionsAnsibleApi.new(api_client(smart_proxy))
        end

        def remote_options
          if root.url.blank?
            super
          else
            common_remote_options.merge(url: root.url.chomp("/"), requirements_file: root.ansible_collection_requirements.blank? ? nil : root.ansible_collection_requirements)
          end
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
