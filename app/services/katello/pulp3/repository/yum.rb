require 'pulp_rpm_client'

module Katello
  module Pulp3
    class Repository
      class Yum < ::Katello::Pulp3::Repository
        def self.api_client(smart_proxy)
          PulpRpmClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpRpmClient::Configuration))
        end

        def self.api_exception_class
          PulpRpmClient::ApiError
        end

        def client_class
          PulpRpmClient
        end

        def remote_class
          PulpRpmClient::RpmRemote
        end

        def self.remotes_api(smart_proxy)
          PulpRpmClient::RemotesRpmApi.new(api_client(smart_proxy))
        end

        def publication_class
          PulpRpmClient::RpmPublication
        end

        def publications_api
          PulpRpmClient::PublicationsRpmApi.new(api_client)
        end

        def distribution_class
          PulpRpmClient::RpmDistribution
        end

        def self.distributions_api(smart_proxy)
          PulpRpmClient::DistributionsRpmApi.new(api_client(smart_proxy))
        end

        def remote_options
          if root.url.blank?
            common_remote_options.merge(url: nil, policy: root.download_policy)
          else
            common_remote_options.merge(policy: root.download_policy)
          end
        end

        def distribution_options(path)
          {
            base_path: path,
            publication: repo.publication_href,
            name: "#{backend_object_name}"
          }
        end
      end
    end
  end
end
