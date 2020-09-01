module Actions
  module Pulp3
    module ContentViewVersion
      class CreateExporter < Pulp3::Abstract
        input_format do
          param :smart_proxy_id, Integer
          param :content_view_version_id, Integer
        end

        def run
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          output[:exporter_data] = ::Katello::Pulp3::ContentViewVersion.new(smart_proxy: smart_proxy,
                                                                            content_view_version: cvv).create_exporter
        end
      end
    end
  end
end
