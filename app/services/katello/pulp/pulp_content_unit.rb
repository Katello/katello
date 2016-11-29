require 'set'

module Katello
  module Pulp
    class PulpContentUnit
      # Any class that extends this class should define:
      # Class::CONTENT_TYPE

      # Any class that extends this class can define:
      # Class.unit_handler (optional)
      # Class::PULP_INDEXED_FIELDS (optional)

      attr_accessor :uuid

      def initialize(uuid)
        self.uuid = uuid
      end

      def self.pulp_data(uuid)
        unit_handler.find_by_unit_id(uuid)
      end

      def self.unit_handler
        Katello.pulp_server.extensions.send(self.name.demodulize.underscore)
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
        self.class.pulp_data(self.uuid)
      end
    end
  end
end
