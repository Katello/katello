require 'set'

module Katello
  module Pulp
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

      def self.pulp_data(uuid)
        unit_handler.find_by_unit_id(uuid)
      end

      def self.model_class
        Katello::RepositoryTypeManager.model_class(self)
      end

      def self.unit_identifier
        "_id"
      end

      def self.content_type
        self::CONTENT_TYPE
      end

      def self.unit_handler
        Katello.pulp_server.extensions.send(self.name.demodulize.underscore)
      end

      def self.pulp_units_batch_all(unit_ids = nil, page_size = SETTINGS[:katello][:pulp][:bulk_load_size])
        fields = self.const_get(:PULP_INDEXED_FIELDS) if self.constants.include?(:PULP_INDEXED_FIELDS)
        criteria = {:limit => page_size, :skip => 0}
        criteria[:fields] = fields if fields
        criteria[:filters] = {'_id' => {'$in' => unit_ids}} if unit_ids

        pulp_units_batch(criteria, page_size) do
          Katello.pulp_server.resources.unit.search(self::CONTENT_TYPE, criteria, :include_repos => true)
        end
      end

      def self.pulp_units_batch_for_repo(repository, options = {})
        page_size = options.fetch(:page_size, SETTINGS[:katello][:pulp][:bulk_load_size])

        fields = self.const_get(:PULP_INDEXED_FIELDS) if self.constants.include?(:PULP_INDEXED_FIELDS)
        criteria = {:type_ids => [const_get(:CONTENT_TYPE)], :limit => page_size, :skip => 0}
        criteria[:fields] = {:unit => fields} if fields

        pulp_units_batch(criteria, page_size) do
          Katello.pulp_server.resources.repository.unit_search(repository.pulp_id, criteria).pluck(:metadata)
        end
      end

      def self.pulp_units_batch(criteria, page_size = SETTINGS[:katello][:pulp][:bulk_load_size], &block)
        response = {}
        Enumerator.new do |yielder|
          loop do
            break if (response.blank? && criteria[:skip] != 0)
            response = block.call
            yielder.yield response
            criteria[:skip] += page_size
          end
        end
      end

      def self.fetch_all
        count = 0
        results = []
        sub_list = fetch(0, SETTINGS[:katello][:pulp][:bulk_load_size])

        until sub_list.empty? #we can't know how many there are, so we have to keep looping until we get nothing
          count += sub_list.count
          if block_given?
            value = yield(sub_list)
            value.is_a?(Array) ? results.concat(value) : results << value
          else
            results.concat(sub_list)
          end

          sub_list = fetch(count, SETTINGS[:katello][:pulp][:bulk_load_size])
        end
        results
      end

      def self.fetch_by_uuids(uuids)
        results = []
        uuids.each_slice(SETTINGS[:katello][:pulp][:bulk_load_size]) do |sub_list|
          fetched = fetch(0, sub_list.length, sub_list)
          if block_given?
            value = yield(fetched)
            value.is_a?(Array) ? results.concat(value) : results << value
          else
            results.concat(fetched)
          end
        end
        results
      end

      def self.ids_for_repository(repo_id)
        criteria = {:type_ids => [const_get(:CONTENT_TYPE)],
                    :fields => {:unit => [], :association => ['unit_id']}}
        Katello.pulp_server.resources.repository.unit_search(repo_id, criteria).map { |i| i['unit_id'] }
      end

      def self.fetch_for_repository(repo_id)
        ids = ids_for_repository(repo_id)
        fetch(0, ids.count, ids)
      end

      def self.fetch(offset, page_size, uuids = nil)
        fields = self.const_get(:PULP_INDEXED_FIELDS) if self.constants.include?(:PULP_INDEXED_FIELDS)
        criteria = {:limit => page_size, :skip => offset}
        criteria[:fields] = fields if fields
        criteria[:filters] = {'_id' => {'$in' => uuids}} if uuids
        Katello.pulp_server.resources.unit.search(self::CONTENT_TYPE, criteria, :include_repos => true)
      end

      def backend_data
        @backend_data ||= fetch_backend_data
        @backend_data.try(:with_indifferent_access)
      end

      def fetch_backend_data
        self.class.pulp_data(self.uuid)
      end

      def self.remove(repo, uuids = nil)
        fields = self.const_get(:PULP_SELECT_FIELDS) if self.constants.include?(:PULP_SELECT_FIELDS)
        clauses = {:association => {'unit_id' => {'$in' => uuids}}}
        clause = { type_ids: [const_get(:CONTENT_TYPE)]}
        clause = clause.merge(filters: clauses) if uuids
        clause = clause.merge(fields: { :unit => fields}) if fields
        Katello.pulp_server.resources.repository.unassociate_units(repo.pulp_id,
                                                                   clause)
      end
    end
  end
end
