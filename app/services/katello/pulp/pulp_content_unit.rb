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
        all_items = items = fetch(0, Katello.config.pulp.bulk_load_size)
        until items.empty? #we can't know how many there are, so we have to keep looping until we get nothing
          items = fetch(all_items.length, Katello.config.pulp.bulk_load_size)
          all_items.concat(items)
        end
        all_items
      end

      def self.fetch_by_uuids(uuids)
        items = []
        uuids.each_slice(Katello.config.pulp.bulk_load_size) do |sub_list|
          items.concat(fetch(0, sub_list.length, sub_list))
        end
        items
      end

      def self.fetch(offset, page_size, uuids = nil)
        fields = ::PULP_INDEXED_FIELDS if self.constants.include?(:PULP_INDEXED_FIELDS)
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
