module Actions
  module Pulp3
    module ContentViewVersion
      class CreateImporter < Pulp3::Abstract
        input_format do
          param :smart_proxy_id, Integer
          param :content_view_version_id, Integer
          param :path, String
        end

        def run
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          output[:importer_data] = ::Katello::Pulp3::ContentViewVersion::Import.new(smart_proxy: smart_proxy,
                                                                            content_view_version: cvv,
                                                                            path: input[:path]).create_importer
        end
      end
    end
  end
end
