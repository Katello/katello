module Actions
  module Pulp3
    module ContentViewVersion
      class DestroyImporter < Pulp3::Abstract
        input_format do
          param :smart_proxy_id, Integer
          param :importer_data, Hash
          param :organization_id, Integer
          param :importer_data, Hash
          param :path, String
          param :metadata, Hash
        end

        def run
          metadata_map = ::Katello::Pulp3::ContentViewVersion::MetadataMap.new(metadata: input[:metadata])
          import = ::Katello::Pulp3::ContentViewVersion::Import.new(
            organization: ::Organization.find(input[:organization_id]),
            smart_proxy: smart_proxy,
            path: input[:path],
            metadata_map: metadata_map
          )
          import.destroy_importer(input[:importer_data][:pulp_href])
        end
      end
    end
  end
end
