module Actions
  module Katello
    module ContentViewVersion
      class Import < Actions::EntryAction
        execution_plan_hooks.use :clean_failed_import, on: :stopped

        def plan(opts = {})
          metadata_map = ::Katello::Pulp3::ContentViewVersion::MetadataMap.new(metadata: opts[:metadata])

          import = ::Katello::Pulp3::ContentViewVersion::Import.new(
            organization: opts[:organization],
            metadata_map: metadata_map,
            path: opts[:path],
            smart_proxy: SmartProxy.pulp_primary!
          )

          import.check!

          gpg_helper = ::Katello::Pulp3::ContentViewVersion::ImportGpgKeys.
                          new(organization: opts[:organization],
                              metadata_gpg_keys: metadata_map.gpg_keys)
          gpg_helper.import!

          sequence do
            plan_action(AutoCreateProducts, { import: import })
            plan_action(AutoCreateRepositories, { import: import, path: opts[:path] })
            plan_action(AutoCreateRedhatRepositories, { import: import, path: opts[:path] })

            if metadata_map.syncable_format?
              plan_action(::Actions::BulkAction,
                    ::Actions::Katello::Repository::Sync,
                    import.intersecting_repos_library_and_metadata.exportable(format: metadata_map.format),
                    { skip_candlepin_check: true }
                    )
            end

            if import.content_view
              plan_action(ResetContentViewRepositoriesFromMetadata, { import: import })
              publish_output = plan_action(::Actions::Katello::ContentView::Publish, import.content_view, metadata_map.content_view_version.description,
                          { path: opts[:path],
                            metadata: opts[:metadata],
                            importing: !metadata_map.syncable_format?,
                            syncable: metadata_map.syncable_format?,
                            major: metadata_map.content_view_version.major,
                            minor: metadata_map.content_view_version.minor,
                          }).output
              plan_self(content_view_id: import.content_view.id, content_view_version_id: publish_output[:content_view_version_id])
            end
          end
        end

        def run
          output[:content_view_version_id] = input[:content_view_version_id]
        end

        def clean_failed_import(execution_plan)
          return unless execution_plan.run_steps.any? { |s| s.action_class == ::Actions::Pulp3::ContentViewVersion::CreateImport && s.state != :success }

          version = ::Katello::ContentViewVersion.find_by(id: output[:content_view_version_id])
          return unless version

          ForemanTasks.async_task(::Actions::Katello::ContentView::Remove, version.content_view,
                        content_view_versions: [version],
                        content_view_environments: version.content_view_environments)
        end

        def humanized_name
          _("Import Content View Version")
        end
      end
    end
  end
end
