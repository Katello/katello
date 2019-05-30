module Katello
  module Pulp
    class Srpm < PulpContentUnit
      include LazyAccessor

      PULP_SELECT_FIELDS = %w(name epoch version release arch checksumtype checksum).freeze
      PULP_INDEXED_FIELDS = %w(name version release arch epoch summary checksum filename).freeze
      CONTENT_TYPE = "srpm".freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data

      lazy_accessor :description, :license, :buildhost, :vendor, :relativepath, :children, :checksumtype,
                    :changelog, :group, :size, :url, :build_time, :group,
                    :initializer => :pulp_facts

      def update_model(model)
        keys = Pulp::Srpm::PULP_INDEXED_FIELDS - ['_id']
        custom_json = backend_data.slice(*keys)
        if custom_json.any? { |name, value| model.send(name) != value }
          custom_json[:release_sortable] = Util::Package.sortable_version(custom_json[:release])
          custom_json[:version_sortable] = Util::Package.sortable_version(custom_json[:version])
          model.assign_attributes(custom_json)
          model.nvra = model.build_nvra
          model.save!
        end
      end
    end
  end
end
