module Actions
  module Pulp3
    module ContentViewVersion
      class CreateSyncableExportHistory < Actions::EntryAction
        input_format do
          param :smart_proxy_id, Integer
          param :base_path, String
          param :content_view_version_id, Integer
          param :destination_server, String
        end

        output_format do
          param :export_history_id, Integer
          param :path, String
        end

        def run
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          output[:path] = input[:base_path]
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          export_metadata = ::Katello::Pulp3::ContentViewVersion::Export.create(
                                                     content_view_version: cvv,
                                                     smart_proxy: smart_proxy,
                                                     format: input[:format]).generate_metadata

          history = ::Katello::ContentViewVersionExportHistory.create!(
            content_view_version_id: input[:content_view_version_id],
            destination_server: input[:destination_server],
            path: input[:base_path],
            metadata: export_metadata,
            audit_comment: ::Katello::ContentViewVersionExportHistory.generate_audit_comment(content_view_version: cvv,
                                                                                             user: User.current,
                                                                                             metadata: export_metadata)
          )
          output[:export_history_id] = history.id
          output[:format] = ::Katello::Pulp3::ContentViewVersion::Export::SYNCABLE
        end

        def humanized_name
          _("Create Syncable Export History")
        end
      end
    end
  end
end
