child :host_collections => :host_collections do
  attributes :id, :name, :description, :max_hosts, :unlimited_hosts

  node :total_hosts do |host_collection|
    host_collection.total_hosts(cached: true)
  end
end
