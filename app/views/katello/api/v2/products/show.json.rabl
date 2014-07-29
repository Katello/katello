object @resource

attributes :id, :cp_id, :name, :label, :description

extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/syncable'

attributes :marketing_product
attributes :provider_id
attributes :sync_plan_id
attributes :sync_status
attributes :gpg_key_id
attributes :redhat? => :redhat

attributes :productContent => :product_content
attributes :available_content

node :repository_count do |product|
  if product.library_repositories.to_a.any?
    product.library_repositories.count
  else
    0
  end
end

child :library_repositories => :repositories do |repo|
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
    :view_products => product.readable?,
    :edit_products => product.editable?,
    :destroy_products => product.deletable?,
    :sync_products => product.syncable?
  }
end

attributes :published_content_views

node :readonly do |product|
  product.redhat? 
end

node :can_remove do |product|
  !product.redhat? && product.published_content_views.length == 0
end

extends 'katello/api/v2/common/timestamps'
