module Actions
  module Pulp3
    module Orchestration
      module ContentViewVersion
        class Export < Actions::EntryAction
          input_format do
            param :smart_proxy_id, Integer
            param :content_view_version_id, Integer
            param :export_history_id, Integer
            param :exporter_data, Hash
            param :destination_server, String
          end

          output_format do
            param :exported_file_name, String
            param :exported_file_checksum, String
          end

          def plan(content_view_version, destination_server:)
            action_subject(content_view_version)
            unless File.directory?(Setting['pulpcore_export_destination'])
              fail ::Foreman::Exception, N_("Unable to export. 'pulpcore_export_destination' setting is not set to a valid directory.")
            end

            sequence do
              smart_proxy = SmartProxy.pulp_primary!
              action_output = plan_action(::Actions::Pulp3::ContentViewVersion::CreateExporter,
                                     content_view_version_id: content_view_version.id,
                                     smart_proxy_id: smart_proxy.id,
                                     destination_server: destination_server).output

              plan_action(::Actions::Pulp3::ContentViewVersion::Export,
                                     content_view_version_id: content_view_version.id,
                                     smart_proxy_id: smart_proxy.id,
                                     exporter_data: action_output[:exporter_data]
                                     )

              plan_self(exporter_data: action_output[:exporter_data], smart_proxy_id: smart_proxy.id,
                        destination_server: destination_server,
                        content_view_version_id: content_view_version.id)

              plan_action(::Actions::Pulp3::ContentViewVersion::DestroyExporter,
                            smart_proxy_id: smart_proxy.id,
                            exporter_data: action_output[:exporter_data])
            end
          end

          def run
            smart_proxy = ::SmartProxy.find(input[:smart_proxy_id])
            api = ::Katello::Pulp3::Api::Core.new(smart_proxy)
            export_data = api.export_api.list(input[:exporter_data][:pulp_href]).results.first
            output[:exported_file_name], output[:exported_file_checksum] = export_data.output_file_info.first
            path = File.dirname(output[:exported_file_name].to_s)
            ::Katello::ContentViewVersionExportHistory.create!(content_view_version_id: input[:content_view_version_id],
                                                               destination_server: input[:destination_server],
                                                               path: path)
            cvv = ::Katello::ContentViewVersion.find(input[:content_view_version_id])

            export_metadata = ::Katello::Pulp3::ContentViewVersion::Export.new(:content_view_version => cvv,
                                                               :smart_proxy => smart_proxy).generate_metadata
            toc = Dir.glob("#{path}/*toc.json").first
            export_metadata[:toc] = File.basename(toc) if toc
            File.write("#{path}/#{::Katello::Pulp3::ContentViewVersion::Export::METADATA_FILE}", export_metadata.to_json)
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
