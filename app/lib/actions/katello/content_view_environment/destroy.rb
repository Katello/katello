module Actions
  module Katello
    module ContentViewEnvironment
      class Destroy < Actions::Base
        def plan(cv_env, options = {})
          skip_cp_update = options.fetch(:skip_candlepin_update, false)
          skip_repo_destroy = options.fetch(:skip_repo_destroy, false)
          organization_destroy = options.fetch(:organization_destroy, false)
          content_view = cv_env.content_view
          environment = cv_env.environment
          content_view.check_remove_from_environment!(environment) unless organization_destroy

          sequence do
            concurrence do
              unless skip_repo_destroy
                content_view.repos(environment).each do |repo|
                  # no need to update the content view environment since it's
                  # getting destroyed so skip_environment_update
                  plan_action(Repository::Destroy, repo, skip_environment_update: true, :planned_destroy => true)
                end
              end

              if puppet_env = content_view.puppet_env(environment)
                plan_action(Actions::Foreman::Environment::Destroy, puppet_env.puppet_environment) if puppet_env.puppet_environment
                plan_action(ContentViewPuppetEnvironment::Destroy, puppet_env) unless organization_destroy
              end
            end
            plan_action(Candlepin::Environment::Destroy, cp_id: cv_env.cp_id) unless skip_cp_update
            plan_self(:id => cv_env.id)
          end
        end

        def finalize
          cv_env = ::Katello::ContentViewEnvironment.find_by(:id => input[:id])
          if cv_env.nil?
            output[:response] = "Content view with ID #{input[:id]} is (probably) already deleted"
          else
            cv_env.destroy!
          end
        end
      end
    end
  end
end
