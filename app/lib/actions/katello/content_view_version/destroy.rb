module Actions
  module Katello
    module ContentViewVersion
      class Destroy < Actions::Base
        def plan(version, options = {})
          version.validate_destroyable!(skip_environment_check: options[:skip_environment_check])

          destroy_env_content = !options.fetch(:skip_destroy_env_content, false)
          repos = destroy_env_content ? version.repositories : version.archived_repos
          docker_cleanup = false

          sequence do
            concurrence do
              repos.each do |repo|
                repo_options = options.clone
                repo_options[:docker_cleanup] = false
                plan_action(Repository::Destroy, repo, **repo_options)
                docker_cleanup ||= repo.docker?
              end
            end
          end

          plan_self(:id => version.id, :docker_cleanup => docker_cleanup)
        end

        def finalize
          version = ::Katello::ContentViewVersion.find_by(id: input[:id])
          version&.destroy!
          ::Katello::DockerMetaTag.cleanup_tags if input[:docker_cleanup]
        end
      end
    end
  end
end
