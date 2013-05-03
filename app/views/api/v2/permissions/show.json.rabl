object @activation_key

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'

attributes :all_tags, :role_id, :tags, :verbs, :all_verbs

attributes :resource_type_id
node :resource_type_name do |permission|
  permission.resource_type.name
end

extends 'api/v2/common/timestamps'
