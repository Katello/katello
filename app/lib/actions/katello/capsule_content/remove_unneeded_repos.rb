module Actions
  module Katello
    module CapsuleContent
      class RemoveUnneededRepos < ::Actions::Base
        def plan(capsule_content)
          repos_currently_on_capsule = capsule_content.current_repositories
          repos_needed_on_capsule = capsule_content.repos_available_to_capsule

          need_removal = repos_currently_on_capsule - repos_needed_on_capsule
          need_removal.each do |repo|
            plan_action(Pulp::Repository::Destroy,
                        :pulp_id => repo.pulp_id,
                        :capsule_id => capsule_content.capsule.id)
          end
        end
      end
    end
  end
end
