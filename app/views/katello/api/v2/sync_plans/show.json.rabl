object @resource

attributes :id, :organization_id
attributes :name, :description
attributes :sync_date, :interval, :next_sync
attributes :created_at, :updated_at
attributes :enabled

child :products => :products do |_product|
  extends 'katello/api/v2/common/syncable'
  attributes :id, :cp_id, :name, :label, :description

  node :repository_count do |prod|
    if prod.repositories.to_a.any?
      prod.repositories.count
    else
      0
    end
  end
end

node :permissions do |sync_plan|
  {
    :view_sync_plans => sync_plan.readable?,
    :edit_sync_plans => sync_plan.editable?,
    :destroy_sync_plans => sync_plan.deletable?
  }
end
