module Katello
  class SystemHostCollection < Katello::Model
    self.include_root_in_json = false

    belongs_to :system, :inverse_of => :system_host_collections, :class_name => 'Katello::System'
    belongs_to :host_collection, :inverse_of => :system_host_collections

    validate :validate_max_content_hosts_not_exceeded

    def validate_max_content_hosts_not_exceeded
      if new_record? && self.host_collection_id
        host_collection = HostCollection.find(self.host_collection_id)
        if (host_collection) && (!host_collection.unlimited_content_hosts) && (host_collection.systems.size >= host_collection.max_content_hosts)
          errors.add :base,
                     _("You cannot have more than %{max_content_hosts} content host(s) associated with host collection '%{host_collection}'.") %
                         { :max_content_hosts => host_collection.max_content_hosts, :host_collection => host_collection.name }
        end
      end
    end
  end
end
