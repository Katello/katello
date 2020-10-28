module Actions
  module Pulp3
    module Orchestration
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

          # rubocop:disable Metrics/MethodLength
          def plan(content_view_version, destination_server:, chunk_size: nil, from_history: nil)
            action_subject(content_view_version)
            unless File.directory?(Setting['pulpcore_export_destination'])
              fail ::Foreman::Exception, N_("Unable to export. 'pulpcore_export_destination' setting is not set to a valid directory.")
            end

            sequence do
              smart_proxy = SmartProxy.pulp_primary!
              from_content_view_version = from_history&.content_view_version
              if from_content_view_version.present?
                export_service = ::Katello::Pulp3::ContentViewVersion::Export.new(
                                                       smart_proxy: smart_proxy,
                                                       content_view_version: content_view_version,
                                                       destination_server: destination_server,
                                                       from_content_view_version: from_content_view_version)
                export_service.validate_incremental_export!
              end

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

              plan_self(exporter_data: action_output[:exporter_data], smart_proxy_id: smart_proxy.id,
                        destination_server: destination_server,
                        content_view_version_id: content_view_version.id,
                        from_content_view_version_id: from_content_view_version&.id)

              plan_action(::Actions::Pulp3::ContentViewVersion::DestroyExporter,
                            smart_proxy_id: smart_proxy.id,
                            exporter_data: action_output[:exporter_data])
            end
          end

          def run
            smart_proxy = ::SmartProxy.find(input[:smart_proxy_id])
            api = ::Katello::Pulp3::Api::Core.new(smart_proxy)
            export_data = api.export_api.list(input[:exporter_data][:pulp_href]).results.first
            output[:exported_file_checksum] = export_data.output_file_info
            file_name = output[:exported_file_checksum].first&.first
            path = File.dirname(file_name.to_s)
            output[:export_path] = path
            cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])
            from_cvv = ::Katello::ContentViewVersion.find(input[:from_content_view_version_id]) unless input[:from_content_view_version_id].blank?

            export_metadata = ::Katello::Pulp3::ContentViewVersion::Export.new(
                                                       content_view_version: cvv,
                                                       smart_proxy: smart_proxy,
                                                       from_content_view_version: from_cvv).generate_metadata
            export_metadata[:incremental] = from_cvv.present?
            toc = Dir.glob("#{path}/*toc.json").first
            export_metadata[:toc] = File.basename(toc) if toc
            history = ::Katello::ContentViewVersionExportHistory.create!(
              content_view_version_id: input[:content_view_version_id],
              destination_server: input[:destination_server],
              path: path,
              metadata: export_metadata
            )
            output[:export_history_id] = history.id
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
end
