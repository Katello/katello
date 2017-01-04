module Actions
  module Katello
    module ContentViewVersion
      class Destroy < Actions::Base
        def plan(version, options = {})
          version.validate_destroyable!(options[:skip_environment_check])

          destroy_env_content = !options.fetch(:skip_destroy_env_content, false)
          repos = destroy_env_content ? version.repositories : version.archived_repos

          puppet_envs = []
          if destroy_env_content
            puppet_envs = version.content_view_puppet_environments
          elsif version.archive_puppet_environment
            puppet_envs = [version.archive_puppet_environment]
          end

          sequence do
            concurrence do
              repos.each do |repo|
                repo_options = options.clone
                repo_options[:planned_destroy] = true
                plan_action(Repository::Destroy, repo, repo_options)
              end
              puppet_envs.each do |cvpe|
                plan_action(ContentViewPuppetEnvironment::Destroy, cvpe) unless version.default?
              end
            end
          end

          plan_self(:id => version.id)
        end

        def finalize
          version = ::Katello::ContentViewVersion.find(input[:id])
          version.destroy!
        end
      end
    end
  end
end
