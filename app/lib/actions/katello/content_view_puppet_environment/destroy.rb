module Actions
  module Katello
    module ContentViewPuppetEnvironment
      class Destroy < Actions::EntryAction
        def plan(puppet_env)
          action_subject(puppet_env)
          plan_action(Pulp::Repository::Destroy, pulp_id: puppet_env.pulp_id)
          plan_self
        end

        def finalize
          puppet_env = ::Katello::ContentViewPuppetEnvironment.
            find(input[:content_view_puppet_environment][:id])

          puppet_env.destroy!
        rescue ActiveRecord::RecordNotFound => e
          output[:response] = e.message
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
