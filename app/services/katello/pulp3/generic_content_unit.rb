module Katello
  module Pulp3
    class GenericContentUnit < PulpContentUnit
      include LazyAccessor
      CONTENT_TYPE = "generic".freeze

      def self.fetch_content_list(page_opts, repository_type, content_type)
        content_unit_list page_opts, repository_type, content_type
      end

      def self.content_unit_list(page_opts, repository_type, content_type)
        self.content_api(repository_type, content_type).list page_opts
      end

      def self.content_api(repository_type, content_type)
        label = content_type.is_a?(String) ? content_type : content_type.label
        repository_type.content_types.find { |type| type.content_type == label }.pulp3_api.new(repository_type.pulp3_api_class.new(SmartProxy.pulp_primary!, repository_type).api_client)
      end

      def self.generate_model_row(unit, content_type)
        {
          pulp_id: unit['pulp_href'],
          name: content_type&.model_name&.call(unit),
          version: content_type&.model_version&.call(unit),
          filename: content_type&.model_filename&.call(unit),
          additional_metadata: content_type&.model_additional_metadata&.call(unit),
          content_type: content_type&.label
        }
      end
    end
  end
end
