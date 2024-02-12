module Actions
  module Pulp3
    module Orchestration
      module ContentViewVersion
        class Import < Actions::EntryAction
          def plan(content_view_version, opts = {})
            action_subject(content_view_version)
            sequence do
              smart_proxy = SmartProxy.pulp_primary!
              importer_output = plan_action(
                ::Actions::Pulp3::ContentViewVersion::CreateImporter,
                content_view_version_id: content_view_version.id,
                smart_proxy_id: smart_proxy.id,
                path: opts[:path],
                metadata: opts[:metadata]
              ).output

              plan_action(
                ::Actions::Pulp3::ContentViewVersion::CreateImport,
                organization_id: content_view_version.content_view.organization_id,
                smart_proxy_id: smart_proxy.id,
                importer_data: importer_output[:importer_data],
                path: opts[:path],
                metadata: opts[:metadata]
              )
              concurrence do
                content_view_version.importable_repositories.each do |repo|
                  plan_action(Actions::Pulp3::Repository::SaveVersion, repo)
                end
              end
              plan_action(
                ::Actions::Pulp3::ContentViewVersion::CreateImportHistory,
                content_view_version_id: content_view_version.id,
                path: opts[:path],
                metadata: opts[:metadata],
                content_view_name: content_view_version.name
              )
              plan_action(::Actions::Pulp3::ContentViewVersion::DestroyImporter,
                            organization_id: content_view_version.content_view.organization_id,
                            smart_proxy_id: smart_proxy.id,
                            path: opts[:path],
                            metadata: opts[:metadata],
                            importer_data: importer_output[:importer_data])
              plan_self(
                content_view_name: content_view_version.name,
                metadata: opts[:metadata],
                path: opts[:path],
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
