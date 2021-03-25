module Actions
  module Katello
    module ContentViewVersion
      class Export < Actions::EntryAction
        input_format do
          param :smart_proxy_id, Integer
          param :content_view_version_id, Integer
          param :from_content_view_version_id, Integer
          param :export_history_id, Integer
          param :exporter_data, Hash
          param :destination_server, String
        end

        output_format do
          param :exported_file_checksum, Hash
          param :export_path, String
        end

        def plan(content_view_version:, destination_server: nil,
                 chunk_size: nil, from_history: nil,
                 validate_incremental: true,
                 fail_on_missing_content: false)
          action_subject(content_view_version)

          sequence do
            smart_proxy = SmartProxy.pulp_primary!
            from_content_view_version = from_history&.content_view_version
            export_service = ::Katello::Pulp3::ContentViewVersion::Export.new(
                                                   smart_proxy: smart_proxy,
                                                   content_view_version: content_view_version,
                                                   destination_server: destination_server,
                                                   from_content_view_version: from_content_view_version)
            export_service.validate!(fail_on_missing_content: fail_on_missing_content,
                                     validate_incremental: validate_incremental)

            action_output = plan_action(::Actions::Pulp3::ContentViewVersion::CreateExporter,
                                   content_view_version_id: content_view_version.id,
                                   smart_proxy_id: smart_proxy.id,
                                   destination_server: destination_server).output

            plan_action(::Actions::Pulp3::ContentViewVersion::Export,
                                   content_view_version_id: content_view_version.id,
                                   smart_proxy_id: smart_proxy.id,
                                   exporter_data: action_output[:exporter_data],
                                   chunk_size: chunk_size,
                                   from_content_view_version_id: from_content_view_version&.id)

            history_output = plan_action(
              ::Actions::Pulp3::ContentViewVersion::CreateExportHistory,
              smart_proxy_id: smart_proxy.id,
              exporter_data: action_output[:exporter_data],
              pulp_href: action_output[:exporter_data][:pulp_href],
              content_view_version_id: content_view_version.id,
              from_content_view_version_id: from_content_view_version&.id,
              destination_server: destination_server
            ).output
            plan_action(::Actions::Pulp3::ContentViewVersion::DestroyExporter,
              smart_proxy_id: smart_proxy.id,
              exporter_data: action_output[:exporter_data])
            plan_self(exporter_data: action_output[:exporter_data], smart_proxy_id: smart_proxy.id,
              destination_server: destination_server,
              content_view_version_id: content_view_version.id,
              from_content_view_version_id: from_content_view_version&.id,
              export_history_id: history_output[:export_history_id],
              exported_file_checksum: history_output[:exported_file_checksum],
              path: history_output[:path])
          end
        end

        def run
          output.update(
            export_history_id: input[:export_history_id],
            export_path: input[:path],
            exported_file_checksum: input[:exported_file_checksum]
          )
        end

        def humanized_name
          _("Export")
        end

        def rescue_strategy
          Dynflow::Action::Rescue::Skip
        end
      end
    end
  end
end
