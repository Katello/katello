object @resource
@resource ||= @object

extends "katello/api/v2/products/base"

attributes :productContent => :product_content

attributes :available_content => :available_content

attributes :redhat? => :redhat

child :library_repositories => :repositories do |_repo|
  attributes :name, :id
end

node(:gpg_key, :unless => lambda { |product| product.gpg_key.nil? }) do |product|
  {:id => product.gpg_key.id, :name => product.gpg_key.name}
end

child :provider do
  attribute :name
end

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

node :redhat do |product|
  product.redhat?
end

node :permissions do |product|
  {
    :destroy_products => product.editable?,
    :edit_products => product.deletable?,
    :sync_products => product.syncable?
  }
end

node :active_task_count do |product|
  ForemanTasks::Task::DynflowTask.for_resource(product).active.count
end

extends 'katello/api/v2/common/timestamps'
