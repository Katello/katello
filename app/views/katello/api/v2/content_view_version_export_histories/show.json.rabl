object @resource

attributes :destination_server, :path, :id

node :content_view_version do |h|
  h.content_view_version.name
end

node :content_view_version_id do |h|
  h.content_view_version.id
end

extends 'katello/api/v2/common/timestamps'
