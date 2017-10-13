module Katello
  module Pulp
    class Srpm < PulpContentUnit
      include LazyAccessor

      PULP_SELECT_FIELDS = %w(name epoch version release arch checksumtype checksum).freeze
      PULP_INDEXED_FIELDS = %w(name version release arch epoch summary sourcerpm checksum filename _id).freeze
      CONTENT_TYPE = "srpm".freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data

      lazy_accessor :description, :license, :buildhost, :vendor, :relativepath, :children, :checksumtype,
                    :changelog, :group, :size, :url, :build_time, :group,
                    :initializer => :pulp_facts
    end
  end
end
