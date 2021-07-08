module Actions
  module Pulp3
    module ContentViewVersion
      class DestroyExporter < Pulp3::AbstractAsyncTask
        input_format do
          param :smart_proxy_id, Integer
          param :exporter_data, Hash
        end

        def invoke_external_task
          ::Katello::Pulp3::ContentViewVersion::Export.new(smart_proxy: smart_proxy).destroy_exporter(input[:exporter_data][:pulp_href])
        end
      end
    end
  end
end
