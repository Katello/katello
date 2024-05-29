object @resource
@resource ||= @object

extends "katello/api/v2/products/base"

attributes :sync_state_aggregated

child(:product_contents => :product_content) do
  extends "katello/api/v2/products/product_content"
end

child(:available_content => :available_content) do
  extends "katello/api/v2/products/product_content"
end

attributes :redhat? => :redhat

child :library_repositories => :repositories do |_repo|
  attributes :name, :id
end

node(:gpg_key, :unless => lambda { |product| product.gpg_key.nil? }) do |product|
  {:id => product.gpg_key.id, :name => product.gpg_key.name}
end

node(:ssl_ca_cert, :unless => lambda { |product| product.ssl_ca_cert.nil? }) do |product|
  {:id => product.ssl_ca_cert.id, :name => product.ssl_ca_cert.name}
end

node(:ssl_client_cert, :unless => lambda { |product| product.ssl_client_cert.nil? }) do |product|
  {:id => product.ssl_client_cert.id, :name => product.ssl_client_cert.name}
end

node(:ssl_client_key, :unless => lambda { |product| product.ssl_client_key.nil? }) do |product|
  {:id => product.ssl_client_key.id, :name => product.ssl_client_key.name}
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
    :error_details => local_sync_status[:error_details],
  }
end

node :permissions do |product|
  {
    :view_products => product.readable?,
    :edit_products => product.editable?,
    :destroy_products => product.deletable?,
    :sync_products => product.syncable?,
  }
end

node(:published_content_view_ids) do |product|
  product.published_content_views.map(&:id).uniq
end

node(:has_last_affected_repo_in_filter) do |product|
  product.repositories.any? { |repo| repo.filters.any? { |filter| filter.repositories.size == 1 } }
end
node :redhat do |product|
  product.redhat?
end

node :active_task_count do |product|
  ForemanTasks::Task::DynflowTask.for_resource(product).active.count
end

extends 'katello/api/v2/common/timestamps'
