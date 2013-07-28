object @resource

attributes :id, :name
attributes :content_view_definition_id

node :content_view_definition_label do |res|
  res.content_view_definition.label
end
node :organization do |res|
  res.content_view_definition.organization.label
end

child :rules do
  extends 'api/v2/filter_rules/show'
end

child :repositories do
  attributes :id, :name
end
child :products do
  attributes :id, :name
end

extends 'api/v2/common/timestamps'