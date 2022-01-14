object @resource

extends 'katello/api/v2/common/identifier'

attributes :pulp_id => :backend_identifier
attributes :relative_path, :container_repository_name, :full_path, :library_instance_id
attributes :version_href, :remote_href, :publication_href
attributes :content_counts
attributes :mirroring_policy

glue(@object.root) do
  attributes :content_type, :url, :arch, :os_versions, :content_id, :generic_remote_options
  attributes :major, :minor
  attributes :supports_errata? => :supports_errata

  child :product do |_product|
    attributes :id, :cp_id, :name
    attributes :orphaned? => :orphaned
    attributes :redhat? => :redhat
    child :sync_plan do |_sync_plan|
      attributes :name, :description, :sync_date, :interval, :next_sync
    end
  end
end

node :content_label do |repo|
  repo.content.try(:label)
end

child :published_in_versions => :content_view_versions do |_version|
  attributes :id, :version
  node :content_view_id do |object|
    object.content_view.id
  end
  node :content_view_name do |object|
    object.content_view.name
  end
end

child :latest_dynflow_sync => :last_sync do |_object|
  attributes :id, :username, :started_at, :ended_at, :state, :result, :progress
end

node :last_sync_words do |object|
  if (object.latest_dynflow_sync.respond_to?('ended_at') && object.latest_dynflow_sync.ended_at)
    time_ago_in_words(Time.parse(object.latest_dynflow_sync.ended_at.to_s))
  elsif (audit = object.latest_sync_audit)
    time_ago_in_words(audit.created_at)
  end
end

child :content_view => :content_view do |_repo|
  attribute :id, :name
end

child :content_view_version do
  attributes :id, :name, :content_view_id
end

child :environment do
  attributes :id, :name
end
