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
    end
  end
end
