object @resource

extends 'katello/api/v2/common/identifier'

attributes :content_type, :url, :relative_path
attributes :pulp_id => :backend_identifier

child :product do |_product|
  attributes :id, :cp_id, :name
  node :sync_plan do |_sync_plan|
    attributes :name, :description, :sync_date, :interval, :next_sync
  end
end

node :content_counts do |repo|
  {
    :ostree_branch => repo.ostree_branches.count,
    :docker_manifest => repo.docker_manifests.count,
    :docker_tag => repo.docker_meta_tag_count,
    :rpm => repo.rpms.count,
    :package => repo.rpms.count,
    :package_group => repo.package_groups.count,
    :erratum => repo.errata.count,
    :puppet_module => repo.puppet_modules.count,
    :file => repo.files.count
  }
end

child :latest_dynflow_sync => :last_sync do |_object|
  attributes :id, :username, :started_at, :ended_at, :state, :result, :progress
end

node :last_sync_words do |object|
  if (object.latest_dynflow_sync.respond_to?('ended_at') && object.latest_dynflow_sync.ended_at)
    time_ago_in_words(Time.parse(object.latest_dynflow_sync.ended_at.to_s))
  end
end
