object @product

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'

attributes :multiplier, :attributes, :marketing_product, :provider_id
attributes :sync_plan_id, :sync_plan_name
attributes :gpg_key_id, :gpg_key_name

extends 'api/v2/common/syncable'
extends 'api/v2/common/timestamps'
