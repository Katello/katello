require "pulpcore_client"

module Katello
  module Pulp3
    module Api
      class Core
        attr_accessor :smart_proxy, :repository_type

        def initialize(smart_proxy, repository_type = Katello::RepositoryTypeManager.find_by(:pulp3_api_class, self.class))
          @smart_proxy = smart_proxy
          @repository_type = repository_type
        end

        def client_module
          repository_type.client_module_class
        end

        delegate :remote_class, to: :repository_type

        def self.remote_uln_class
          fail NotImplementedError
        end

        delegate :distribution_class, to: :repository_type

        delegate :publication_class, to: :repository_type

        def repository_sync_url_class
          repository_type.repo_sync_url_class
        end

        def api_client
          config = smart_proxy.pulp3_configuration(repository_type.configuration_class)
          config.params_encoder = Faraday::FlatParamsEncoder
          api_client_class(repository_type.api_class.new(config))
        end

        def api_exception_class
          client_module::ApiError
        end

        def remotes_api
          repository_type.remotes_api_class.new(api_client)
        end

        def remotes_uln_api
          fail NotImplementedError
        end

        def publications_api
          repository_type.publications_api_class.new(api_client) #Optional
        end

        def distributions_api
          repository_type.distributions_api_class.new(api_client)
        end

        def core_repositories_api
          PulpcoreClient::RepositoriesApi.new(core_api_client)
        end

        def repositories_api
          repository_type.repositories_api_class.new(api_client)
        end

        def repository_versions_api
          repository_type.repository_versions_api_class.new(api_client)
        end

        def self.ignore_409_exception(*)
          yield
        rescue => e
          raise e unless e&.code == 409
          nil
        end

        def repository_version_class
          client_module::RepositoryVersion
        end

        def cancel_task(task_href)
          data = PulpcoreClient::TaskResponse.new(state: 'canceled')
          self.class.ignore_409_exception do
            tasks_api.tasks_cancel(task_href, data)
          end
        end

        def repositories_reclaim_space_api
          PulpcoreClient::RepositoriesReclaimSpaceApi.new(core_api_client)
        end

        def exporter_api
          PulpcoreClient::ExportersPulpApi.new(core_api_client)
        end

        def importer_api
          PulpcoreClient::ImportersPulpApi.new(core_api_client)
        end

        def importer_check_api
          PulpcoreClient::ImportersPulpImportCheckApi.new(core_api_client)
        end

        def export_api
          PulpcoreClient::ExportersPulpExportsApi.new(core_api_client)
        end

        def import_api
          PulpcoreClient::ImportersPulpImportsApi.new(core_api_client)
        end

        def orphans_api
          PulpcoreClient::OrphansApi.new(core_api_client)
        end

        def artifacts_api
          PulpcoreClient::ArtifactsApi.new(core_api_client)
        end

        def core_api_client
          client = PulpcoreClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpcoreClient::Configuration))
          api_client_class(client)
        end

        def api_client_class(client)
          request_id = ::Logging.mdc['request']
          client.default_headers['Correlation-ID'] = request_id if request_id
          client
        end

        def uploads_api
          PulpcoreClient::UploadsApi.new(core_api_client)
        end

        def upload_commit_class
          PulpcoreClient::UploadCommit
        end

        def signing_services_api
          PulpcoreClient::SigningServicesApi.new(core_api_client)
        end

        def tasks_api
          PulpcoreClient::TasksApi.new(core_api_client)
        end

        def task_groups_api
          PulpcoreClient::TaskGroupsApi.new(core_api_client)
        end

        def upload_class
          PulpcoreClient::Upload
        end

        def ignore_404_exception(*)
          yield
        rescue self.api_exception_class => e
          raise e unless e.code == 404
          nil
        end

        def delete_orphans
          [orphans_api.delete]
        end

        def delete_remote(remote_href)
          ignore_404_exception { remotes_api.delete(remote_href) }
        end

        def repository_version_hrefs(options = {})
          repository_versions(options).map(&:pulp_href).uniq
        end

        def repository_versions(options = {})
          current_pulp_repositories = self.list_all(options)
          repo_hrefs = current_pulp_repositories.collect { |repo| repo.pulp_href }.uniq

          version_hrefs = repo_hrefs.collect do |href|
            versions_list_for_repository(href, options)
          end

          version_hrefs.flatten
        end

        def versions_list_for_repository(repository_href, options)
          self.class.fetch_from_list { |page_opts| repository_versions_api.list(repository_href, page_opts.merge(options)) }
        end

        def distributions_list_all(args = {})
          self.class.fetch_from_list do |page_opts|
            distributions_api.list(page_opts.merge(args))
          end
        end

        def get_distribution(href)
          ignore_404_exception { distributions_api.read(href) }
        end

        def delete_distribution(href)
          ignore_404_exception { distributions_api.delete(href) }
        end

        def core_repositories_list_all(options = {})
          self.class.fetch_from_list do |page_opts|
            core_repositories_api.list(page_opts.merge(options))
          end
        end

        def list_all(options = {})
          self.class.fetch_from_list do |page_opts|
            repositories_api.list(page_opts.merge(options))
          end
        end

        def remotes_list(args = {})
          remotes_api.list(args).results
        end

        def remotes_list_all(_smart_proxy, options)
          self.class.fetch_from_list do |page_opts|
            remotes_api.list(page_opts.merge(options))
          end
        end

        def self.fetch_from_list
          page_size = Setting[:bulk_load_size]
          page_opts = { "offset" => 0, limit: page_size }
          response = {}

          results = []

          loop do
            page_opts = page_opts.with_indifferent_access
            break unless (
            (response.count && (page_opts['offset'] < response.count)) ||
                page_opts["offset"] == 0)
            response = yield page_opts
            results = results.concat(response.results)
            page_opts[:offset] += page_size
          end

          results
        end
      end
    end
  end
end
