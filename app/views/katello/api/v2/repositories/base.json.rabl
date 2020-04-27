object @resource

extends 'katello/api/v2/common/identifier'

attributes :pulp_id => :backend_identifier
attributes :relative_path, :container_repository_name, :full_path, :library_instance_id

glue(@object.root) do
  attributes :content_type, :url, :arch, :content_id
  attributes :major, :minor

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

node :content_counts do |repo|
  {
    :ostree_branch => repo.ostree_branches.count,
    :docker_manifest => repo.docker_manifests.count,
    :docker_manifest_list => repo.docker_manifest_lists.count,
    :docker_tag => repo.docker_meta_tag_count,
    :rpm => repo.rpms.count,
    :srpm => repo.srpms.count,
    :package => repo.rpms.count,
    :package_group => repo.package_groups.count,
    :erratum => repo.errata.count,
    :puppet_module => repo.puppet_modules.count,
    :file => repo.files.count,
    :deb => repo.debs.count,
    :module_stream => repo.module_streams.count,
    :ansible_collection => repo.ansible_collections.count
  }
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
