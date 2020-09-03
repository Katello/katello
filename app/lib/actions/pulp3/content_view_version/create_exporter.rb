module Actions
  module Pulp3
    module ContentViewVersion
      class CreateExporter < Pulp3::Abstract
        input_format do
          param :smart_proxy_id, Integer
          param :content_view_version_id, Integer
          param :destination_server, String
        end

        def run
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          output[:exporter_data] = ::Katello::Pulp3::ContentViewVersion::Export.new(smart_proxy: smart_proxy,
                                                                            content_view_version: cvv,
                                                                            destination_server: input[:destination_server]).create_exporter
        end
      end
    end
  end
end
