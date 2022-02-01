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

              plan_action(
                ::Actions::Pulp3::ContentViewVersion::Import,
                content_view_version_id: content_view_version.id,
                smart_proxy_id: smart_proxy.id,
                importer_data: importer_output[:importer_data],
                path: path,
                metadata: metadata
              )
              concurrence do
                content_view_version.importable_repositories.each do |repo|
                  plan_action(Actions::Pulp3::Repository::SaveVersion, repo)
                end
              end
              plan_action(
                ::Actions::Pulp3::ContentViewVersion::CreateImportHistory,
                content_view_version_id: content_view_version.id,
                path: path,
                metadata: metadata,
                content_view_name: content_view_version.name
              )
              plan_action(::Actions::Pulp3::ContentViewVersion::DestroyImporter,
                            smart_proxy_id: smart_proxy.id,
                            importer_data: importer_output[:importer_data])
              plan_self(
                content_view_name: content_view_version.name,
                metadata: metadata,
                path: path,
                content_view_version_id: content_view_version.id
              )
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
