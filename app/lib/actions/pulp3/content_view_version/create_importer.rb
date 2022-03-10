module Actions
  module Pulp3
    module ContentViewVersion
      class CreateImporter < Pulp3::Abstract
        input_format do
          param :smart_proxy_id, Integer
          param :content_view_version_id, Integer
          param :path, String
          param :metadata, Hash
        end

        def run
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          metadata_map = ::Katello::Pulp3::ContentViewVersion::MetadataMap.new(metadata: input[:metadata])
          output[:importer_data] = ::Katello::Pulp3::ContentViewVersion::Import.new(
            organization: cvv.content_view.organization,
            smart_proxy: smart_proxy,
            path: input[:path],
            metadata_map: metadata_map
          ).create_importer(cvv)
        end
      end
    end
  end
end
