object @resource

attributes :cp_id => :id
attributes :name, :label, :description

extends 'api/v2/common/org_reference'

attributes :multiplier, :marketing_product
attributes :provider_id
attributes :sync_plan_id, :sync_plan_name
attributes :gpg_key_id

node :repository_count do |product|
  product.repositories.length
end

child :gpg_key do
  attributes :id, :name
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
