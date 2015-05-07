module Actions
  module Pulp
    module Repos
      class Update < Pulp::Abstract
        def plan(product)
          sync_plan = product.sync_plan

          product.repos(product.library).each do |repo|
            if sync_plan.nil?
              plan_action(::Actions::Pulp::Repository::RemoveSchedule, :repo_id => repo.id)
            else
              plan_action(::Actions::Pulp::Repository::UpdateSchedule,
                :repo_id => repo.id,
                :schedule => sync_plan.schedule_format,
                :enabled => sync_plan.enabled
              )
            end
          end
        end
      end
    end
  end
end
