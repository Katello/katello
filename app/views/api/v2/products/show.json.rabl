object @resource

attributes :cp_id => :id
attributes :name, :label, :description

extends 'api/v2/common/org_reference'

attributes :multiplier, :marketing_product, :provider_id
attributes :sync_plan_id, :sync_plan_name
attributes :gpg_key_id, :gpg_key_name

child :provider do |r|
  attribute :name
end

extends 'api/v2/common/syncable'
extends 'api/v2/common/timestamps'
