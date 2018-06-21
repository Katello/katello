module Actions
  module Katello
    module SyncPlan
      class Destroy < Actions::EntryAction
        def plan(sync_plan)
          action_subject(sync_plan)

          sync_plan.products.each do |product|
            plan_action(::Actions::Katello::Product::Update, product, :sync_plan_id => nil)
          end

          plan_self
        end

        def finalize
          sync_plan = ::Katello::SyncPlan.find(input[:sync_plan][:id])
          recurring_logic = sync_plan.recurring_logic
          sync_plan.destroy!
          recurring_logic.destroy!
        end

        def humanized_name
          _("Delete")
        end
      end
    end
  end
end
