object @resource

extends 'katello/api/v2/common/identifier'

attributes :version, :major, :minor
attributes :composite_content_view_ids
attributes :published_in_composite_content_view_ids
attributes :content_view_id
attributes :default
attributes :description

node do |version|
  version.content_counts_map
end

child :content_view => :content_view do
  attributes :id, :name, :label
end

child :composite_content_views => :composite_content_views do
  attributes :id, :name, :label
end

child :composites => :composite_content_view_versions do
  attributes :id, :content_view_id, :version
end

child :published_in_composite_content_views => :published_in_composite_content_views do
  attributes :id, :name, :label
end

node :permissions do |cvv|
  {
    :deletable => cvv.removable?
  }
end

extends 'katello/api/v2/common/timestamps'
