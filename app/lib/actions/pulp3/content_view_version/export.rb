module Actions
  module Pulp3
    module ContentViewVersion
      class Export < Pulp3::AbstractAsyncTask
        input_format do
          param :content_view_version_id, Integer
          param :from_content_view_version_id, Integer
          param :smart_proxy_id, Integer
          param :exporter_data, Hash
          param :chunk_size, Integer
        end

        def invoke_external_task
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          from_cvv = ::Katello::ContentViewVersion.find(input[:from_content_view_version_id]) unless input[:from_content_view_version_id].blank?
          ::Katello::Pulp3::ContentViewVersion::Export.new(smart_proxy: smart_proxy,
                                                   content_view_version: cvv,
                                                   from_content_view_version: from_cvv).create_export(input[:exporter_data][:pulp_href],
                                                                                            chunk_size: input[:chunk_size])
        end
      end
    end
  end
end
