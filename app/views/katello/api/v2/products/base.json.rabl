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
  status = product.sync_status
  {
    :id => status[:id],
    :product_id => status[:product_id],
    :progress => status[:progress],
    :sync_id => status[:sync_id],
    :state => status[:state],
    :raw_state => status[:raw_state],
    :start_time => status[:start_time],
    :finish_time => status[:finish_time],
    :duration => status[:duration],
    :display_size => status[:display_size],
    :size => status[:size],
    :is_running => status[:is_running],
    :error_details => status[:error_details]
  }
end

child :sync_plan do
  attributes :name, :description, :sync_date, :interval, :next_sync
end

node :repository_count do |product|
  product.library_repositories.count
end
