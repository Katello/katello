module Actions
  module Katello
    module ContentView
      class NodeMetadataGenerate < Actions::EntryAction
        def resource_locks
          :link
        end

        def humanized_name
          _("Generate and Synchronize Capsule Metadata for %s") % input[:environment_name]
        end

        def plan(content_view, environment)
          action_subject(content_view)

          concurrence do
            ::Katello::Repository.in_content_views([content_view]).in_environment(environment).each do |repo|
              plan_action(Katello::Repository::NodeMetadataGenerate, repo)
            end

            cv_puppet_env = ::Katello::ContentViewPuppetEnvironment.in_environment(environment).
                in_content_view(content_view).first
            plan_action(Katello::Repository::NodeMetadataGenerate, cv_puppet_env)
          end
          plan_self(:environment_name => environment.name)
        end
      end
    end
  end
end
