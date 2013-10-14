object @resource

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'
extends 'api/v2/common/timestamps'

attributes :content

child :products do
  attributes :cp_id => :id
  attributes :name
end

child :repositories do
  attributes :id, :name
end

