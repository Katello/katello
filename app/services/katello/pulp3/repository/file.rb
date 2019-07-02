require 'pulp_file_client'

module Katello
  module Pulp3
    class Repository
      class File < ::Katello::Pulp3::Repository
        def api_exception_class
          PulpFileClient::ApiError
        end

        def remote_class
          PulpFileClient::FileRemote
        end

        def self.api_client(smart_proxy)
          PulpFileClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpFileClient::Configuration))
        end

        def remotes_api
          PulpFileClient::RemotesFileApi.new(api_client)
        end

        def publication_class
          PulpFileClient::FilePublication
        end

        def publications_api
          PulpFileClient::PublicationsFileApi.new(api_client)
        end

        def distribution_class
          PulpFileClient::FileDistribution
        end

        def distributions_api
          PulpFileClient::DistributionsFileApi.new(api_client)
        end

        def copy_content_for_source(source_repository, _options = {})
          copy_units_by_href(source_repository.files.pluck(:pulp_id))
        end

        def distribution_options(path)
          {
            base_path: path,
            publication: repo.publication_href,
            name: "#{backend_object_name}"
          }
        end

        def remote_options
          #TODO: move to user specifying PULP_MANIFEST
          if root.url.blank?
            common_remote_options.merge(url: nil)
          else
            common_remote_options.merge(url: root.url + '/PULP_MANIFEST')
          end
        end

        def partial_repo_path
          "/pulp/isos/#{repo.relative_path}/PULP_MANIFEST"
        end
      end
    end
  end
end
