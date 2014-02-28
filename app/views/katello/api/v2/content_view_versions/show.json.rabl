object @resource

extends 'katello/api/v2/common/identifier'

attributes :version
attributes :composite_content_view_ids

child :content_view => :content_view do
  attributes :id, :name, :label
end

child :composite_content_views do
  attributes :id, :name, :label
end

extends 'katello/api/v2/common/timestamps'
