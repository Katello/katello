object @activation_key

attributes :id, :name, :description, :organization_id, :environment_id
attributes :usage_count, :user_id, :usage_limit, :pools, :system_template_id

extends 'api/v2/common/timestamps'
