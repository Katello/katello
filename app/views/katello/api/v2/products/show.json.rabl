object @resource

attributes :id, :cp_id, :name, :label, :description

extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/syncable'

attributes :provider_id
attributes :sync_plan_id
attributes :sync_status
attributes :sync_summary
attributes :gpg_key_id
attributes :redhat? => :redhat

attributes :productContent => :product_content

attributes :available_content => :available_content

node :repository_count do |product|
  product.library_repositories.count
end

child :library_repositories => :repositories do |_repo|
  attributes :name, :id
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
    :view_products => product.readable?,
    :edit_products => product.editable?,
    :destroy_products => product.deletable?,
    :sync_products => product.syncable?
  }
end

node(:published_content_view_ids) do |product|
  product.published_content_views.map(&:id).uniq
end

node :readonly do |product|
  product.redhat?
end

extends 'katello/api/v2/common/timestamps'
