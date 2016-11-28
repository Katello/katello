module Actions
  module Katello
    module SyncPlan
      class AddProducts < Actions::EntryAction
        middleware.use Actions::Middleware::PulpServicesCheck

        def plan(sync_plan, product_ids)
          action_subject(sync_plan)

          ::Katello::Repository.ensure_sync_notification

          products = ::Katello::Product.where(:id => product_ids).editable
          sync_plan.product_ids = (sync_plan.product_ids + products.collect { |p| p.id }).uniq
          sync_plan.save!

          products.each do |product|
            plan_action(::Actions::Katello::Product::Update, product, :sync_plan_id => sync_plan.id)
          end
        end

        def humanized_name
          _("Add Sync Plan Products")
        end
      end
    end
  end
end
