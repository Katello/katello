object @resource

attributes :id, :cp_id, :name, :label, :description

extends 'katello/api/v2/common/syncable'
extends 'katello/api/v2/common/org_reference'

attributes :provider_id
attributes :sync_plan_id
attributes :sync_status
attributes :sync_summary
attributes :gpg_key_id
attributes :redhat? => :redhat

attributes :available_content => :available_content, :if => params[:include_available_content]

child :sync_plan do
  attributes :name, :description, :sync_date, :interval, :next_sync
end

node :repository_count do |product|
  product.library_repositories.count
end
