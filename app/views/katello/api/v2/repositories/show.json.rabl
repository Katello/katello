object @resource

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'
extends 'katello/api/v2/common/syncable'

attributes :content_type
attributes :unprotected, :full_path
attributes :url,
           :relative_path
attributes :major, :minor
attributes :gpg_key_id
attributes :content_id, :content_view_version_id, :library_instance_id
attributes :product_type

node :content_counts do |repo|
  if repo.respond_to?(:pulp_repo_facts)
    repo.pulp_repo_facts['content_unit_counts']
  end
end

node :permissions do |repo|
  {
    :deletable => repo.deletable?
  }
end

child :gpg_key do |gpg|
  attribute :name
  attribute :id
end

child :product do |product|
  attribute :id
  attribute :cp_id
  attribute :name
  node :sync_plan do |sync_plan|
    partial('katello/api/v2/sync_plans/show', :object => product.sync_plan)
  end
end

child :environment => :environment do |repo|
  attribute :id
end

child :gpg_key do
  attributes :id, :name
end
