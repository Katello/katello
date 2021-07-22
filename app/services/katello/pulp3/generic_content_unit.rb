module Katello
  module Pulp3
    class GenericContentUnit < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "generic_content_unit".freeze

      def self.fetch_content_list(page_opts, repository_type, content_type)
        content_unit_list page_opts, repository_type, content_type
      end

      def self.content_unit_list(page_opts, repository_type, content_type)
        self.content_api(repository_type, content_type).list page_opts
      end

      def self.content_api(repository_type, content_type)
        repository_type.content_types.find { |type| type.content_type == content_type }.pulp3_api.new(repository_type.pulp3_api_class.new(SmartProxy.pulp_primary!, repository_type).api_client)
      end

      def update_model(model, repository_type, content_type)
        custom_json = {}
        custom_json['pulp_id'] = backend_data['pulp_href']
        custom_json['name'] = repository_type.model_name.call(backend_data)
        custom_json['version'] = repository_type.model_version.call(backend_data)
        custom_json['content_type'] = content_type
        model.update!(custom_json)
      end
    end
  end
end
