module Actions
  module Pulp3
    module Orchestration
      module ContentViewVersion
        class ExportRepository < Actions::EntryAction
          def plan(repository,
                    chunk_size: nil,
                    from_history: nil)
            action_subject(repository)
            validate_repositories_immediate!(repository)

            content_view = ::Katello::Pulp3::ContentViewVersion::Export.find_repository_export_view(
                                                                           repository: repository,
                                                                           create_by_default: true)
            content_view.update!(repository_ids: [repository.library_instance_or_self.id])

            sequence do
              publish_action = plan_action(::Actions::Katello::ContentView::Publish, content_view, '')
              export_action = plan_action(Actions::Katello::ContentViewVersion::Export,
                                          content_view_version: publish_action.version,
                                          chunk_size: chunk_size,
                                          from_history: from_history)
              plan_self(export_action_output: export_action.output)
            end
          end

          def run
            output[:export_history_id] = input[:export_action_output][:export_history_id]
          end

          def humanized_name
            _("Export Repository")
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end

          def validate_repositories_immediate!(repository)
            unless repository.immediate?
              fail _("NOTE: Unable to fully export repository '%{repository}' because"\
                     " it does not have the 'immediate' download policy."\
                     " Update the download policy and sync the affected repository to include them in the export."\
                       % { repository: repository.name })
            end
          end
        end
      end
    end
  end
end
