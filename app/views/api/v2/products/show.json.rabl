object @product

attributes :id, :name, :description, :multiplier, :attributes, :marketing_product, :provider_id
attributes :sync_plan_id, :sync_plan_name
attributes :gpg_key_id, :gpg_key_name

extends 'api/v2/common/syncable'
extends 'api/v2/common/timestamps'
