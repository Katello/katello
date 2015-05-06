module Actions
  module Katello
    module SyncPlan
      class Update < Actions::EntryAction
        def plan(sync_plan, sync_plan_params = nil)
          action_subject(sync_plan)
          sync_plan.update_attributes(sync_plan_params) if sync_plan_params
          sync_plan.save!
          sync_plan.products.each do |product|
            plan_action(::Actions::Katello::Product::Update, product, :sync_plan_id => sync_plan.id)
          end
        end

        def humanized_name
          _("Update Sync Plan")
        end
      end
    end
  end
end
