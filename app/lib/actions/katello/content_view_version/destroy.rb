module Actions
  module Katello
    module ContentViewVersion
      class Destroy < Actions::Base
        def plan(version, options = {})
          version.check_ready_to_destroy! unless options[:skip_environment_check]

          sequence do
            concurrence do
              version.repositories.each do |repo|
                repo_options = options.clone
                repo_options[:planned_destroy] = true
                plan_action(Repository::Destroy, repo, repo_options)
              end
              version.content_view_puppet_environments.each do |cvpe|
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
