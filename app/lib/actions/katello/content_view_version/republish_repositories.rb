module Actions
  module Katello
    module ContentViewVersion
      class RepublishRepositories < Actions::EntryAction
        def plan(content_view_version)
          action_subject(content_view_version.content_view)
          plan_self(:version_id => content_view_version.id)

          content_view_version.repositories.each do |repo|
            plan_action(::Actions::Katello::Repository::MetadataGenerate, repo, :force => true)
          end

          content_view_version.content_view_puppet_environments.each do |repo|
            plan_action(::Actions::Katello::Repository::MetadataGenerate, repo, :force => true)
          end
        end

        def run
          #dummy run phase to save input
        end

        def resource_locks
          :link
        end

        def humanized_name
          if input[:version_id]
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
