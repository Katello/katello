object @product

attributes :cp_id => :id
attributes :name, :label, :description

extends 'api/v2/common/org_reference'

attributes :multiplier, :marketing_product, :provider_id
attributes :sync_plan_id, :sync_plan_name
attributes :gpg_key_id, :gpg_key_name

extends 'api/v2/common/syncable'
extends 'api/v2/common/timestamps'
