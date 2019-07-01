require 'set'
require 'pulp_file_client'

module Katello
  module Pulp3
    class PulpContentUnit
      # Any class that extends this class should define:
      # Class::CONTENT_TYPE
      # Class#update_model

      # Any class that extends this class can define:
      # Class.unit_handler (optional)
      # Class::PULP_INDEXED_FIELDS (optional)

      attr_accessor :uuid
      attr_writer :backend_data

      def initialize(uuid)
        self.uuid = uuid
      end

      def self.model_class
        Katello::RepositoryTypeManager.model_class(self)
      end

      def self.unit_identifier
        "_href"
      end

      def self.pulp_units_batch_for_repo(repository, page_size = SETTINGS[:katello][:pulp][:bulk_load_size])
        repository_version_href = repository.version_href
        page_opts = { "page" => 1, repository_version: repository_version_href, page_size: page_size}
        response = {}
        Enumerator.new do |yielder|
          loop do
            page_opts = page_opts.with_indifferent_access
            break unless (response["next"] || page_opts["page"] == 1)
            response = fetch_content_list page_opts
            response = response.as_json.with_indifferent_access
            yielder.yield response[:results]
            page_opts[:page] += 1
          end
        end
      end

      def self.pulp_data(_href)
        fail NotImplementedError
      end

      def self.fetch_all
        fail NotImplementedError
      end

      def self.fetch_by_href(_href)
        fail NotImplementedError
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
