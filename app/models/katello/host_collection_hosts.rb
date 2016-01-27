module Katello
  class HostCollectionHosts < Katello::Model
    self.include_root_in_json = false

    belongs_to :host, :inverse_of => :host_collection_hosts, :class_name => 'Host::Managed'
    belongs_to :host_collection, :inverse_of => :host_collection_hosts

    validate :validate_max_hosts_not_exceeded

    def validate_max_hosts_not_exceeded
      if new_record? && self.host_collection_id
        host_collection = HostCollection.find(self.host_collection_id)
        if (host_collection) && (!host_collection.unlimited_hosts) && (host_collection.hosts.size >= host_collection.max_hosts)
          errors.add :base,
                     _("You cannot have more than %{max_hosts} host(s) associated with host collection '%{host_collection}'.") %
                         { :max_hosts => host_collection.max_hosts, :host_collection => host_collection.name }
        end
      end
    end
  end
end
