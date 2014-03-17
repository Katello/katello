object @resource

attributes :id, :cp_id, :name, :label, :description

extends 'katello/api/v2/common/org_reference'

attributes :marketing_product
attributes :provider_id
attributes :sync_plan_id
attributes :sync_status
attributes :gpg_key_id
attributes :productContent

node :repository_count do |product|
  if product.library_repositories.to_a.any?
    product.library_repositories.enabled.count
  else
    0
  end
end

child :repositories => :library_repositories do
    extends 'katello/api/v2/repositories/show'
end

node(:gpg_key, :unless => lambda { |product| product.gpg_key.nil? }) do |product|
  {:id => product.gpg_key.id, :name => product.gpg_key.name}
end

child :provider do
  attribute :name
end

child :sync_plan do
  extends 'katello/api/v2/sync_plans/show'
end

node :permissions do |product|
  {
    :deletable => product.deletable?
  }
end

extends 'katello/api/v2/common/timestamps'
extends 'katello/api/v2/common/readonly'
