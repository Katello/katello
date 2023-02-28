module Actions
  module Pulp3
    module Orchestration
      module ContentViewVersion
        class SyncableExport < Actions::EntryAction
          input_format do
            param :smart_proxy_id, Integer
            param :content_view_version_id, Integer
            param :export_history_id, Integer
            param :export_path, String
            param :from_content_view_version_id, Integer
          end

          output_format do
            param :export_path, String
            param :export_history_id, Integer
          end

          def plan(content_view_version:,
                   smart_proxy:,
                   fail_on_missing_content: false,
                   destination_server:,
                   from_content_view_version:)
            format = ::Katello::Pulp3::ContentViewVersion::Export::SYNCABLE
            sequence do
              export_service = ::Katello::Pulp3::ContentViewVersion::Export.create(
                  smart_proxy: smart_proxy,
                  content_view_version: content_view_version,
                  from_content_view_version: from_content_view_version,
                  format: format,
                  destination_server: destination_server)
              base_path = export_service.generate_exporter_path
              export_service.repositories.each do |repository|
                action_output = plan_action(::Actions::Pulp3::ContentViewVersion::CreateExporter,
                                            content_view_version_id: content_view_version.id,
                                            smart_proxy_id: smart_proxy.id,
                                            format: format,
                                            base_path: base_path,
                                            repository_id: repository.id,
                                            destination_server: destination_server).output

                plan_action(::Actions::Pulp3::ContentViewVersion::Export,
                            content_view_version_id: content_view_version.id,
                            smart_proxy_id: smart_proxy.id,
                            exporter_data: action_output[:exporter_data],
                            format: format,
                            repository_id: repository.id,
                            from_content_view_version_id:  from_content_view_version&.id)

                plan_action(::Actions::Pulp3::ContentViewVersion::DestroyExporter,
                          smart_proxy_id: smart_proxy.id,
                          exporter_data: action_output[:exporter_data],
                          format: format,
                          repository_id: repository.id)
              end

              history_output = plan_action(
                  ::Actions::Pulp3::ContentViewVersion::CreateSyncableExportHistory,
                  smart_proxy_id: smart_proxy.id,
                  content_view_version_id: content_view_version.id,
                  from_content_view_version_id:  from_content_view_version&.id,
                  destination_server: destination_server,
                  format: format,
                  base_path: base_path
              ).output

              plan_self(export_history_id: history_output[:export_history_id],
                        export_path: base_path)
            end
          end

          def run
            output.update(
                export_history_id: input[:export_history_id],
                export_path: input[:export_path]
            )
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end
        end
      end
    end
  end
end
