object @resource

extends 'katello/api/v2/common/identifier'

child :content_view => :content_view do
  extends 'katello/api/v2/content_views/show'
end

child :repositories => :repositories do
  attributes :id, :name, :label
end

node(:type) { |filter| filter.type.constantize::CONTENT_TYPE }
attributes :parameters

extends 'katello/api/v2/common/timestamps'
