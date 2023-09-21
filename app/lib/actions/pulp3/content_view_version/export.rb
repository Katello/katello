module Actions
  module Pulp3
    module ContentViewVersion
      class Export < Pulp3::AbstractAsyncTask
        input_format do
          param :content_view_version_id, Integer
          param :from_content_view_version_id, Integer
          param :smart_proxy_id, Integer
          param :exporter_data, Hash
          param :format, String
          param :chunk_size, Integer
          param :repository_id, Integer
        end

        def invoke_external_task
          repository = ::Katello::Repository.find(input[:repository_id]) unless input[:repository_id].blank?
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          from_cvv = ::Katello::ContentViewVersion.find(input[:from_content_view_version_id]) unless input[:from_content_view_version_id].blank?
          ::Katello::Pulp3::ContentViewVersion::Export.create(smart_proxy: smart_proxy,
                                                   content_view_version: cvv,
                                                   from_content_view_version: from_cvv,
                                                   format: input[:format],
                                                   repository: repository)
                                                   .create_export(input[:exporter_data],
                                                                        chunk_size: input[:chunk_size])
        end

        def rescue_external_task(error)
          if error.is_a?(::Katello::Errors::Pulp3Error) && error.message.match?(/Remote artifacts cannot be exported/)
            fail ::Katello::Errors::Pulp3ExportError, "Failed to export: One or more repositories needs to be synced (with Immediate download policy.)"
          else
            super
          end
        end
      end
    end
  end
end
