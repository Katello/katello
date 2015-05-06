module Actions
  module Katello
    module SyncPlan
      class RemoveProducts < Actions::EntryAction
        def plan(sync_plan, product_ids)
          action_subject(sync_plan)

          products = ::Katello::Product.where(:id => product_ids).editable
          sync_plan.product_ids = (sync_plan.product_ids - products.collect { |p| p.id }).uniq
          sync_plan.save!

          products.each do |product|
            plan_action(::Actions::Katello::Product::Update, product, :sync_plan_id => nil)
          end
        end

        def humanized_name
          _("Update Sync Plan Products")
        end
      end
    end
  end
end
