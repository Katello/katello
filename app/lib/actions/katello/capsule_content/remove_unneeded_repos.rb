module Actions
  module Katello
    module CapsuleContent
      class RemoveUnneededRepos < ::Actions::Base
        def plan(capsule_content)
          currently_on_capsule = capsule_content.current_repositories.map(&:pulp_id)
          needed_on_capsule = capsule_content.repos_available_to_capsule.map(&:pulp_id)

          need_removal = currently_on_capsule - needed_on_capsule
          need_removal += capsule_content.orphaned_repos
          need_removal.each do |pulp_id|
            plan_action(Pulp::Repository::Destroy,
                        :pulp_id => pulp_id,
                        :capsule_id => capsule_content.capsule.id)
          end
        end
      end
    end
  end
end
