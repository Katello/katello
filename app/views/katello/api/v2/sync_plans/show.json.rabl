object @resource

attributes :id, :organization_id
attributes :name, :description
attributes :sync_date, :interval, :next_sync
attributes :created_at, :updated_at


child :products => :products do |product|
  attributes :id, :cp_id, :name, :label, :description

  node :repository_count do |product|
    if product.repositories.to_a.any?
      product.repositories.count
    else
      0
    end
  end
end
