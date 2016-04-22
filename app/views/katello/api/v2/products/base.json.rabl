object @resource

attributes :id, :cp_id, :name, :label, :description

extends 'katello/api/v2/common/syncable'
extends 'katello/api/v2/common/org_reference'

attributes :provider_id
attributes :sync_plan_id
attributes :sync_summary
attributes :gpg_key_id
attributes :redhat? => :redhat

attributes :available_content => :available_content, :if => params[:include_available_content]

node :sync_status do |product|
  local_sync_status = product.sync_status
  {
    :id => local_sync_status[:id],
    :product_id => local_sync_status[:product_id],
    :progress => local_sync_status[:progress],
    :sync_id => local_sync_status[:sync_id],
    :state => local_sync_status[:state],
    :raw_state => local_sync_status[:raw_state],
    :start_time => local_sync_status[:start_time],
    :finish_time => local_sync_status[:finish_time],
    :duration => local_sync_status[:duration],
    :display_size => local_sync_status[:display_size],
    :size => local_sync_status[:size],
    :is_running => local_sync_status[:is_running],
    :error_details => local_sync_status[:error_details]
  }
end

child :sync_plan do
  attributes :name, :description, :sync_date, :interval, :next_sync
end

node :repository_count do |product|
  product.library_repositories.count
end
