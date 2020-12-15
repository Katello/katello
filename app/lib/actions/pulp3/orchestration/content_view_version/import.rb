module Actions
  module Pulp3
    module Orchestration
      module ContentViewVersion
        class Import < Actions::EntryAction
          def plan(content_view_version, path:, metadata:)
            action_subject(content_view_version)
            sequence do
              smart_proxy = SmartProxy.pulp_primary!
              importer_output = plan_action(
                ::Actions::Pulp3::ContentViewVersion::CreateImporter,
                content_view_version_id: content_view_version.id,
                smart_proxy_id: smart_proxy.id,
                path: path,
                metadata: metadata
              ).output

              import_output = plan_action(
                ::Actions::Pulp3::ContentViewVersion::Import,
                content_view_version_id: content_view_version.id,
                smart_proxy_id: smart_proxy.id,
                importer_data: importer_output[:importer_data],
                path: path,
                metadata: metadata
              ).output

              plan_action(Actions::Pulp3::Repository::SaveVersions, content_view_version.importable_repositories.pluck(:id),
                          tasks: import_output[:pulp_tasks])

              plan_action(::Actions::Pulp3::ContentViewVersion::DestroyImporter,
                            smart_proxy_id: smart_proxy.id,
                            importer_data: importer_output[:importer_data])
            end
          end

          def humanized_name
            _("Import")
          end
        end
      end
    end
  end
end
