module Actions
  module Katello
    module ContentViewVersion
      class Export < Actions::EntryAction
        output_format do
          param :exported_file_checksum, Hash
          param :export_path, String
        end

        def plan(options)
          action_subject(options.fetch(:content_view_version))

          sequence do
            export_output = plan_action(::Actions::Pulp3::Orchestration::ContentViewVersion::Export, **options).output

            plan_self(export_history_id: export_output[:export_history_id],
                      exported_file_checksum: export_output[:exported_file_checksum],
                      export_path: export_output[:export_path])
          end
        end

        def run
          output.update(
            export_history_id: input[:export_history_id],
            export_path: input[:export_path],
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
