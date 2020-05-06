require 'set'
require 'pulp_file_client'

module Katello
  module Pulp3
    class PulpContentUnit
      # Any class that extends this class should define:
      # Class#update_model

      def self.content_api
        fail NotImplementedError
      end

      def self.create_content
        fail NotImplementedError
      end

      def self.backend_unit_identifier
        nil
      end

      def update_model
        fail NotImplementedError
      end

      attr_accessor :uuid
      attr_writer :backend_data

      def initialize(uuid)
        self.uuid = uuid
      end

      def self.model_class
        Katello::RepositoryTypeManager.model_class(self)
      end

      def self.unit_identifier
        "pulp_href"
      end

      def self.content_type
        self::CONTENT_TYPE
      end

      def self.pulp_units_batch_all(content_unit_hrefs)
        Enumerator.new do |yielder|
          yielder.yield content_unit_hrefs.collect { |href| pulp_data(href) }
        end
      end

      def self.pulp_units_batch_for_repo(repository, options = {})
        fetch_identifiers = options.fetch(:fetch_identifiers, false)
        page_size = options.fetch(:page_size, SETTINGS[:katello][:pulp][:bulk_load_size])
        repository_version_href = repository.version_href
        page_opts = { "offset" => 0, repository_version: repository_version_href, limit: page_size }
        page_opts[:fields] = self.const_get(:PULP_INDEXED_FIELDS).join(",") if self.constants.include?(:PULP_INDEXED_FIELDS)
        page_opts[:fields] = 'pulp_href' if fetch_identifiers
        response = {}
        Enumerator.new do |yielder|
          loop do
            page_opts = page_opts.with_indifferent_access
            break unless (
              (response["count"] && page_opts["offset"] < response["count"]) ||
              page_opts["offset"] == 0)
            page_opts = page_options page_opts
            response = fetch_content_list page_opts
            response = response.as_json.with_indifferent_access
            yielder.yield response[:results]
            page_opts[:offset] += page_size
          end
        end
      end

      def self.page_options(page_opts = {})
        page_opts
      end

      def self.pulp_data(href)
        content_unit = self.content_api.read(href)
        content_unit.as_json
      end

      def self.content_unit_list(page_opts)
        self.content_api.list page_opts
      end

      def backend_data
        @backend_data ||= fetch_backend_data
        @backend_data.try(:with_indifferent_access)
      end

      def fetch_backend_data
        self.class.pulp_data(self.uuid)
      end

      def self.fetch_content_list(page_opts)
        content_unit_list page_opts
      end
    end
  end
end
