module Katello
  module Pulp
    class Rpm < PulpContentUnit
      include LazyAccessor

      PULP_SELECT_FIELDS = %w(name epoch version release arch checksumtype checksum).freeze
      PULP_INDEXED_FIELDS = %w(name version release arch epoch summary sourcerpm checksum filename _id).freeze
      CONTENT_TYPE = "rpm".freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data

      lazy_accessor :description, :license, :buildhost, :vendor, :relativepath, :children, :checksumtype,
                    :changelog, :group, :size, :url, :build_time, :group,
                    :initializer => :pulp_facts

      def requires
        if pulp_facts['requires']
          pulp_facts['requires'].map { |entry| Katello::Util::Package.format_requires(entry) }.uniq.sort
        else
          []
        end
      end

      def provides
        if pulp_facts['provides']
          pulp_facts['provides'].map { |entry| Katello::Util::Package.build_nvrea(entry, false) }.uniq.sort
        else
          []
        end
      end

      def files
        if pulp_facts['files']
          pulp_facts['files']['file'] + pulp_facts['files']['dir']
        else
          []
        end
      end
    end
  end
end
