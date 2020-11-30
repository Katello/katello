module Actions
  module Pulp3
    module Orchestration
      module ContentViewVersion
        class ExportLibrary < Actions::EntryAction
          def plan(organization, destination_server: nil, chunk_size: nil, from_history: nil)
            action_subject(organization)
            content_view = ::Katello::ContentView.find_library_export_view(destination_server: destination_server,
                                                                           organization: organization,
                                                                           create_by_default: true)
            repo_ids_in_library = organization.default_content_view_version.repositories.yum_type.pluck(:id)
            content_view.update!(repository_ids: repo_ids_in_library)

            sequence do
              publish_action = plan_action(::Actions::Katello::ContentView::Publish, content_view, '')
              export_action = plan_action(::Actions::Pulp3::Orchestration::ContentViewVersion::Export,
                                          content_view_version: publish_action.version,
                                          destination_server: destination_server,
                                          chunk_size: chunk_size,
                                          from_history: from_history,
                                          validate_incremental: false)
              plan_self(export_action_output: export_action.output)
            end
          end

          def run
            output[:export_history_id] = input[:export_action_output][:export_history_id]
          end

          def humanized_name
            _("Export Library")
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end
        end
      end
    end
  end
end
