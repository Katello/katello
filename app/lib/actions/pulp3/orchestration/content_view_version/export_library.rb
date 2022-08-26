module Actions
  module Pulp3
    module Orchestration
      module ContentViewVersion
        class ExportLibrary < Actions::EntryAction
          def plan(organization, destination_server: nil,
                                 chunk_size: nil,
                                 from_history: nil,
                                 fail_on_missing_content: false,
                                 format: ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE)
            action_subject(organization)
            validate_repositories_immediate!(organization) if fail_on_missing_content
            content_view = ::Katello::Pulp3::ContentViewVersion::Export.find_library_export_view(destination_server: destination_server,
                                                                           organization: organization,
                                                                           create_by_default: true,
                                                                           format: format)
            repo_ids_in_library = organization.default_content_view_version.repositories.exportable(format: format).immediate_or_none.pluck(:id)
            content_view.update!(repository_ids: repo_ids_in_library)

            sequence do
              publish_action = plan_action(::Actions::Katello::ContentView::Publish, content_view, '')
              export_action = plan_action(Actions::Katello::ContentViewVersion::Export,
                                          content_view_version: publish_action.version,
                                          destination_server: destination_server,
                                          chunk_size: chunk_size,
                                          from_history: from_history,
                                          validate_incremental: false,
                                          fail_on_missing_content: fail_on_missing_content,
                                          format: format)
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

          def validate_repositories_immediate!(organization)
            non_immediate_repos = organization.default_content_view_version.repositories.yum_type.non_immediate
            if non_immediate_repos.any?
              fail _("NOTE: Unable to fully export '%{organization}' organization's library because"\
                     " it contains repositories without the 'immediate' download policy."\
                     " Update the download policy and sync affected repositories to include them in the export."\
                     " \n %{repos}" %
                     { organization: organization.name,
                       repos: ::Katello::Pulp3::ContentViewVersion::Export
                              .generate_product_repo_strings(repositories: non_immediate_repos)})
            end
          end
        end
      end
    end
  end
end
