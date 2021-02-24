class RemoveDisabledProductsFromSyncPlans < ActiveRecord::Migration[6.0]
  def change
    disabled = ::Katello::Product.redhat.where.not(:id => Katello::Product.enabled)
    disabled.update_all(:sync_plan_id => nil)
  end
end
