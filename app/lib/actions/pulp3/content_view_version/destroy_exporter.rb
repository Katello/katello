module Actions
  module Pulp3
    module ContentViewVersion
      class DestroyExporter < Pulp3::Abstract
        input_format do
          param :smart_proxy_id, Integer
          param :exporter_data, Hash
        end

        def run
          ::Katello::Pulp3::ContentViewVersion.new(smart_proxy: smart_proxy).destroy_exporter(input[:exporter_data][:pulp_href])
        end
      end
    end
  end
end
