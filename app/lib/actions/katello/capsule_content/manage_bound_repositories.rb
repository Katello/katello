module Actions
  module Katello
    module CapsuleContent
      class ManageBoundRepositories < ::Actions::EntryAction
        # @param capsule_content [::Katello::CapsuleContent]
        # @param pulp_repo [::Katello::Glue::Pulp::Repo]
        def plan(capsule_content)
          fail _("Action not allowed for the default capsule.") if capsule_content.default_capsule?

          needed_repo_ids = capsule_content.pulp_repos.map(&:pulp_id)
          current_repo_ids = capsule_content.consumer.bound_node_repos
          to_add = needed_repo_ids - current_repo_ids
          to_remove = current_repo_ids - needed_repo_ids

          to_add.each do |pulp_id|
            plan_action(Pulp::Consumer::BindNodeDistributor,
                        consumer_uuid: capsule_content.consumer_uuid,
                        repo_id: pulp_id,
                        bind_options: bind_options)
          end

          to_remove.each do |pulp_id|
            plan_action(Pulp::Consumer::UnbindNodeDistributor,
                                  consumer_uuid: capsule_content.consumer_uuid,
                                  repo_id: pulp_id)
          end
        end

        private

        def bind_options
          { notify_agent: false, binding_config: { strategy: 'mirror' } }
        end
      end
    end
  end
end
