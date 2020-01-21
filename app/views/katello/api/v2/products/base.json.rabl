object @resource

attributes :id, :cp_id, :name, :label, :description

extends 'katello/api/v2/common/syncable'
extends 'katello/api/v2/common/org_reference'

attributes :provider_id
attributes :sync_plan_id
attributes :sync_summary
attributes :sync_state_aggregated
attributes :gpg_key_id
attributes :ssl_ca_cert_id
attributes :ssl_client_cert_id
attributes :ssl_client_key_id

child({:available_content => :available_content}, :if => params[:include_available_content]) do
  extends "katello/api/v2/products/product_content"
end

child :sync_plan do
  attributes :id, :name, :description, :sync_date, :interval, :next_sync, :cron_expression
end

node :repository_count do |product|
  product.root_repositories.count
end
