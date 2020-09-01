module Actions
  module Pulp3
    module ContentViewVersion
      class Export < Pulp3::AbstractAsyncTask
        input_format do
          param :content_view_version_id, Integer
          param :smart_proxy_id, Integer
          param :exporter_data, Hash
        end

        def invoke_external_task
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          ::Katello::Pulp3::ContentViewVersion.new(smart_proxy: smart_proxy,
                                                   content_view_version: cvv).create_export(input[:exporter_data][:pulp_href])
        end
      end
    end
  end
end
