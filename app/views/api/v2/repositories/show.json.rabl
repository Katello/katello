object @resource

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'
extends 'api/v2/common/timestamps'
extends 'api/v2/common/syncable'

attributes :content_type
attributes :unprotected, :full_path
attributes :feed,
           :relative_path,
           :enabled
attributes :major, :minor
attributes :gpg_key_id
attributes :content_id, :content_view_version_id, :library_instance_id

node :content_counts do |repo|
  repo.pulp_repo_facts['content_unit_counts']
end

node :permissions do |repo|
  {
    :deletable => repo.deletable?
  }
end

child :product do |product|
  attribute :cp_id
end

child :environment => :environment do |repo|
  attribute :id
end

child :gpg_key do
  attributes :id, :name
end
