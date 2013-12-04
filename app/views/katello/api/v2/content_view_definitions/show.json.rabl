object @resource

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

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

extends 'katello/api/v2/common/timestamps'
