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

      def self.pulp_data(_uuid)
        fail NotImplemented
      end

      def self.fetch_by_hrefs(hrefs)
        results = []
        hrefs.each do |href|
          fetched = fetch_href(href)
          if block_given?
            value = yield(fetched)
          end
          results << (fetched)
        end
        results
      end

      def self.fetch_by_repo(repo)
        repo = Katello::Pulp3::Repository::File.new(repo, SmartProxy.pulp_master)
        repo_content_list = repo.content_list
        results = []
        repo_content_list.each_slice(SETTINGS[:katello][:pulp][:bulk_load_size]) do |content|
          if block_given?
            value = yield(content)
          end
          results << (content.map!(&:_href))
        end
        results
      end

      def self.fetch_href(href)
        pulp_data(href)
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
