module Actions
  module Pulp3
    module Orchestration
      module ContentViewVersion
        class ExportRepository < Actions::EntryAction
          def plan(repository,
                    chunk_size: nil,
                    from_history: nil,
                    format: ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE)
            action_subject(repository)
            validate_repositories_immediate!(repository)
            validate_export_types!(repository, format)
            content_view = ::Katello::Pulp3::ContentViewVersion::Export.find_repository_export_view(
                                                                           repository: repository,
                                                                           create_by_default: true,
                                                                           format: format)
            content_view.update!(repository_ids: [repository.library_instance_or_self.id])

            sequence do
              publish_action = plan_action(::Actions::Katello::ContentView::Publish, content_view, '')
              export_action = plan_action(Actions::Katello::ContentViewVersion::Export,
                                          content_view_version: publish_action.version,
                                          chunk_size: chunk_size,
                                          from_history: from_history,
                                          format: format)
              plan_self(export_action_output: export_action.output)
            end
          end

          def run
            output[:export_history_id] = input[:export_action_output]&.[](:export_history_id)
          end

          def humanized_name
            _("Export Repository")
          end

          def rescue_strategy
            Dynflow::Action::Rescue::Skip
          end

          def validate_repositories_immediate!(repository)
            unless repository.download_policy.blank? || repository.immediate?
              fail _("NOTE: Unable to fully export repository '%{repository}' because"\
                     " it does not have the 'immediate' download policy."\
                     " Update the download policy and sync the affected repository to include them in the export."\
                       % { repository: repository.name })
            end
          end

          def validate_export_types!(repository, format)
            return if ::Katello::Repository.exportable(format: format).where(id: repository.id).exists?
            if format == ::Katello::Pulp3::ContentViewVersion::Export::SYNCABLE
              fail _("NOTE: Unable to export repository '%{repository}' because"\
                     " it does not have an syncably exportable content type."\
                       % { repository: repository.name })
            end

            fail _("NOTE: Unable to export repository '%{repository}' because"\
                   " it does not have an exportable content type."\
                     % { repository: repository.name })
          end
        end
      end
    end
  end
end
