module Katello
  module Glue::ElasticSearch::HostCollection
    def self.included(base)
      base.class_eval do
        add_system_hook lambda { |system| system.update_host_collections }
        remove_system_hook lambda { |system| system.update_host_collections }
      end
    end
  end
end
