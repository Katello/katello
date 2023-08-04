module Actions
  module Katello
    module ContentViewVersion
      class RepublishRepositories < Actions::EntryAction
        def plan(content_view_version, options = {force: false})
          force = options[:force]
          action_subject(content_view_version.content_view)
          plan_self(:version_id => content_view_version.id)
          repositories = if force
                           content_view_version.repositories
                         else
                           content_view_version.repositories.joins(:root).where.not(root: { mirroring_policy: ::Katello::RootRepository::MIRRORING_POLICY_COMPLETE })
                         end
          plan_action(::Actions::Katello::Repository::BulkMetadataGenerate, repositories)
        end

        def run
          #dummy run phase to save input
        end

        def resource_locks
          :link
        end

        def humanized_name
          if input && input[:version_id]
            version = ::Katello::ContentViewVersion.find_by(:id => input[:version_id])
          end

          if version
            _("Republish Repositories of %{name} %{version}") % {:name => version.content_view.name, :version => version.version}
          else
            _("Republish Version Repositories")
          end
        end
      end
    end
  end
end
