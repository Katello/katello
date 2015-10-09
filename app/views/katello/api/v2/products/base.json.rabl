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

attributes :sync_status do
    attributes :id, :product_id, :progress, :sync_id, :state, :raw_state, :start_time, :finish_time,
                   :duration, :display_size, :size, :is_running, :error_details
end

child :sync_plan do
  attributes :name, :description, :sync_date, :interval, :next_sync
end

node :repository_count do |product|
  product.library_repositories.count
end
