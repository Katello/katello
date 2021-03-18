object @resource

attributes :path, :id, :metadata
attributes :import_type => :type

node :content_view_version do |h|
  h.content_view_version.name
end

node :content_view_version_id do |h|
  h.content_view_version.id
end

extends 'katello/api/v2/common/timestamps'
