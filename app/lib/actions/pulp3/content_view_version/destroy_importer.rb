module Actions
  module Pulp3
    module ContentViewVersion
      class DestroyImporter < Pulp3::Abstract
        input_format do
          param :smart_proxy_id, Integer
          param :importer_data, Hash
        end

        def run
          ::Katello::Pulp3::ContentViewVersion::Import.new(smart_proxy: smart_proxy).destroy_importer(input[:importer_data][:pulp_href])
        end
      end
    end
  end
end
