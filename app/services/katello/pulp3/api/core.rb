require "pulpcore_client"
# rubocop:disable Metrics/ClassLength

module Katello
  module Pulp3
    module Api
      class Core
        attr_accessor :smart_proxy

        def initialize(smart_proxy)
          @smart_proxy = smart_proxy
        end

        def self.api_exception_class
          fail NotImplementedError
        end

        def self.client_module
          fail NotImplementedError
        end

        def self.remote_class
          fail NotImplementedError
        end

        def self.distribution_class
          fail NotImplementedError
        end

        def self.publication_class
          fail NotImplementedError
        end

        def api_client
          fail NotImplementedError
        end

        def remotes_api
          fail NotImplementedError
        end

        def publications_api
          fail NotImplementedError #Optional
        end

        def distributions_api
          fail NotImplementedError
        end

        def repositories_api
          fail NotImplementedError
        end

        def repository_versions_api
          fail NotImplementedError
        end

        def orphans_api
          PulpcoreClient::OrphansApi.new(core_api_client)
        end

        def core_api_client
          PulpcoreClient::ApiClient.new(smart_proxy.pulp3_configuration(PulpcoreClient::Configuration))
        end

        def uploads_api
          PulpcoreClient::UploadsApi.new(core_api_client)
        end

        def tasks_api
          PulpcoreClient::TasksApi.new(core_api_client)
        end

        def upload_class
          PulpcoreClient::Upload
        end

        def delete_orphans
          [orphans_api.delete]
        end

        def delete_remote(remote_href)
          remotes_api.delete(remote_href)
        end

        def repository_versions(options = {})
          current_pulp_repositories = self.list_all(options)
          repo_hrefs = current_pulp_repositories.collect { |repo| repo.pulp_href }.uniq

          version_hrefs = repo_hrefs.collect do |href|
            versions_list_for_repository(href, options).map(&:pulp_href)
          end

          version_hrefs.flatten.uniq
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
          distributions_api.read(href)
        rescue self.class.api_exception_class => e
          raise e if e.code != 404
          nil
        end

        def delete_distribution(href)
          distributions_api.delete(href)
        rescue self.class.api_exception_class => e
          raise e if e.code != 404
          nil
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
          page_size = SETTINGS[:katello][:pulp][:bulk_load_size]
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
