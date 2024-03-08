module Actions
  module Katello
    module ContentViewVersion
      class VerifyChecksum < Actions::EntryAction
        def plan(content_view_version)
          action_subject(content_view_version.content_view)
          plan_self(:version_id => content_view_version.id)
          plan_action(::Actions::BulkAction, ::Actions::Katello::Repository::VerifyChecksum, content_view_version.repositories) if content_view_version.repositories.any?
        end

        def run
          #dummy run phase to save input and support humanized_name
        end

        def humanized_name
          if input && input[:version_id]
            version = ::Katello::ContentViewVersion.find_by(:id => input[:version_id])
          end

          if version
            _("Verify checksum of repositories in %{name} %{version}") % {:name => version.content_view.name, :version => version.version}
          else
            _("Verify checksum of version repositories")
          end
        end
      end
    end
  end
end
