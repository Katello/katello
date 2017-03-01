module Katello
  module Pulp
    class FileUnit < PulpContentUnit
      include LazyAccessor

      PULP_SELECT_FIELDS = %w(name checksum).freeze
      PULP_INDEXED_FIELDS = %w(name checksum _id).freeze
      CONTENT_TYPE = "iso".freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data
    end
  end
end
