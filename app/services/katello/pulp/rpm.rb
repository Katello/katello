module Katello
  module Pulp
    class Rpm < PulpContentUnit
      include LazyAccessor

      PULP_SELECT_FIELDS = %w(name epoch version release arch checksumtype checksum).freeze
      PULP_INDEXED_FIELDS = %w(name version release arch epoch summary sourcerpm checksum filename _id is_modular).freeze
      CONTENT_TYPE = "rpm".freeze

      lazy_accessor :description, :license, :buildhost, :vendor, :relativepath, :children, :checksumtype,
                    :changelog, :group, :size, :url, :build_time, :group,
                    :initializer => :backend_data

      def requires
        if backend_data['requires']
          backend_data['requires'].map { |entry| Katello::Util::Package.format_requires(entry) }.uniq.sort
        else
          []
        end
      end

      def provides
        if backend_data['provides']
          backend_data['provides'].map { |entry| Katello::Util::Package.build_nvrea(entry, false) }.uniq.sort
        else
          []
        end
      end

      def files
        result = []
        if backend_data['files']
          if backend_data['files']['file']
            result << backend_data['files']['file']
          end
          if backend_data['files']['dir']
            result << backend_data['files']['dir']
          end
        end
        result.flatten
      end

      def update_model(model)
        keys = PULP_INDEXED_FIELDS - ['_id', 'is_modular']
        data = backend_data.slice(*keys)
        data['modular'] = backend_data['is_modular']
        if data.any? { |name, value| model.send(name) != value }
          data[:release_sortable] = Util::Package.sortable_version(data[:release])
          data[:version_sortable] = Util::Package.sortable_version(data[:version])
          model.assign_attributes(data)
          model.nvra = model.build_nvra
          model.save!
        end
      end
    end
  end
end
