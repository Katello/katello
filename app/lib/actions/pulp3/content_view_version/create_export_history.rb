module Actions
  module Pulp3
    module ContentViewVersion
      class CreateExportHistory < Actions::EntryAction
        input_format do
          param :smart_proxy_id, Integer
          param :exporter_data, Hash
          param :content_view_version_id, Integer
          param :from_content_view_version_id, Integer
          param :destination_server, String
        end

        output_format do
          param :export_history_id, Integer
          param :path, String
          param :exported_file_checksum, String
        end

        def run # rubocop:disable Metrics/AbcSize
          smart_proxy = ::SmartProxy.unscoped.find(input[:smart_proxy_id])
          api = ::Katello::Pulp3::Api::Core.new(smart_proxy)
          export_data = api.export_api.list(input[:exporter_data][:pulp_href]).results.first
          output[:exported_file_checksum] = export_data.output_file_info
          if output[:exported_file_checksum].blank?
            output[:export_history_id] = nil
            output[:message] = _("Export failed: One or more repositories needs to be synced (with Immediate download policy.)")
            return
          end
          file_name = output[:exported_file_checksum].first&.first
          path = File.dirname(file_name.to_s)
          output[:path] = path
          cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
          from_cvv = ::Katello::ContentViewVersion.find(input[:from_content_view_version_id]) unless input[:from_content_view_version_id].blank?

          export_metadata = ::Katello::Pulp3::ContentViewVersion::Export.create(
                                                     content_view_version: cvv,
                                                     smart_proxy: smart_proxy,
                                                     format: ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE,
                                                     from_content_view_version: from_cvv).generate_metadata

          toc_path_info = output[:exported_file_checksum].find { |item| item.first.end_with?("toc.json") }
          export_metadata[:toc] = File.basename(toc_path_info.first)

          history = ::Katello::ContentViewVersionExportHistory.create!(
            content_view_version_id: input[:content_view_version_id],
            destination_server: input[:destination_server],
            path: path,
            metadata: export_metadata,
            audit_comment: ::Katello::ContentViewVersionExportHistory.generate_audit_comment(content_view_version: cvv,
                                                                                             user: User.current,
                                                                                             from_version: from_cvv,
                                                                                             metadata: export_metadata)
          )
          output[:export_history_id] = history.id
          output[:format] = ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE
        end

        def humanized_name
          _("Create Export History")
        end
      end
    end
  end
end
