object @resource

attributes :cp_id => :id
attributes :name, :label, :description

extends 'api/v2/common/org_reference'

attributes :marketing_product
attributes :provider_id
attributes :sync_plan_id, :sync_plan_name
attributes :gpg_key_id

node :repository_count do |product|
  product.repositories.enabled.count
end

node :gpg_key do |product|
  if !product.gpg_key.nil?
    {
      id: product.gpg_key.id,
      name: product.gpg_key.name
    }
  end
end

child :provider do
  attribute :name
end

node :permissions do |product|
  {
    :deletable => product.deletable?
  }
end

extends 'api/v2/common/timestamps'
extends 'api/v2/common/readonly'
