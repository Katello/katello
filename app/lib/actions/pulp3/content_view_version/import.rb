module Actions
  module Pulp3
    module ContentViewVersion
      class Import < Pulp3::AbstractAsyncTask
        input_format do
          param :content_view_version_id, Integer
          param :smart_proxy_id, Integer
          param :importer_data, Hash
          param :path, String
        end

        def invoke_external_task
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          output[:pulp_tasks] = ::Katello::Pulp3::ContentViewVersion::Import.new(smart_proxy: smart_proxy,
                                                   content_view_version: cvv,
                                                   path: input[:path]).create_import(input[:importer_data][:pulp_href])
        end
      end
    end
  end
end
