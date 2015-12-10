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
  {
    :id => product.sync_status[:id],
    :product_id => product.sync_status[:product_id],
    :progress => product.sync_status[:progress],
    :sync_id => product.sync_status[:sync_id],
    :state => product.sync_status[:state],
    :raw_state => product.sync_status[:raw_state],
    :start_time => product.sync_status[:start_time],
    :finish_time => product.sync_status[:finish_time],
    :duration => product.sync_status[:duration],
    :display_size => product.sync_status[:display_size],
    :size => product.sync_status[:size],
    :is_running => product.sync_status[:is_running],
    :error_details => product.sync_status[:error_details]
  }
end

child :sync_plan do
  attributes :name, :description, :sync_date, :interval, :next_sync
end

node :repository_count do |product|
  product.library_repositories.count
end
