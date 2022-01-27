object @resource

attributes :destination_server, :path, :id, :metadata
attributes :export_type => :type

node :content_view_version do |h|
  h.content_view_version.name unless h.content_view_version_id.blank?
end

node :content_view_version_id do |h|
  h.content_view_version.id unless h.content_view_version_id.blank?
end
extends 'katello/api/v2/common/timestamps'
