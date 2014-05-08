attribute :pulp_id, :name, :organization_id, :max_content_hosts, :description, :total_content_hosts

node :id do |host_collection|
  host_collection.id.to_i
end

extends "katello/api/v2/common/timestamps"

node :permissions do |host_collection|
  {
    :deletable => host_collection.deletable?,
    :editable => host_collection.editable?,
    :content_hosts_readable => host_collection.content_hosts_readable?,
    :content_hosts_editable => host_collection.content_hosts_editable?
  }
end
