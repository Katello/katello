module Katello
  module Pulp
    class FileUnit < PulpContentUnit
      include LazyAccessor

      PULP_SELECT_FIELDS = %w(name checksum).freeze
      PULP_INDEXED_FIELDS = %w(name checksum).freeze
      CONTENT_TYPE = "iso".freeze

      lazy_accessor :pulp_facts, :initializer => :backend_data

      def update_model(model)
        custom_json = {}
        custom_json['checksum'] = backend_data['checksum']
        custom_json['path'] = backend_data['name']
        custom_json['name'] = File.basename(backend_data['name'])
        model.update!(custom_json)
      end
    end
  end
end
