object @resource

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'

attributes :components, :composite

child :content_views => :content_views do
  attributes :id, :name
end
child :repos => :repositories do
  attributes :id, :name
end
child :products => :products do
  attributes :id, :name
end

extends 'api/v2/common/timestamps'
