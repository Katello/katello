object @activation_key

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'

attributes :environment_id
attributes :usage_count, :user_id, :usage_limit, :pools, :system_template_id

extends 'api/v2/common/timestamps'
