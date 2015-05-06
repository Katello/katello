module Actions
  module Katello
    module System
      class ActivationKeys < Actions::Base
        def plan(system, activation_keys)
          activation_keys ||= []

          set_environment_and_content_view(system, activation_keys)
          set_host_collections(system, activation_keys)
          set_association(system, activation_keys)
        end

        def set_association(system, activation_keys)
          system.activation_keys = activation_keys
        end

        def set_environment_and_content_view(system, activation_keys)
          return if system.content_view

          activation_key = activation_keys.reverse.detect do |act_key|
            act_key.environment && act_key.content_view
          end
          if activation_key
            system.environment = activation_key.environment
            system.content_view = activation_key.content_view
          else
            fail _('At least one activation key must have a lifecycle environment and content view assigned to it')
          end
        end

        def set_host_collections(system, activation_keys)
          host_collection_ids = activation_keys.flat_map(&:host_collection_ids).compact.uniq

          host_collection_ids.each do |host_collection_id|
            host_collection = ::Katello::HostCollection.find(host_collection_id)
            if !host_collection.unlimited_content_hosts && host_collection.max_content_hosts >= 0 &&
               host_collection.systems.length >= host_collection.max_content_hosts
              fail _("Host collection '%{name}' exceeds maximum usage limit of '%{limit}'") %
                       {:limit => host_collection.max_content_hosts, :name => host_collection.name}
            end
          end
          system.host_collection_ids = host_collection_ids
        end
      end
    end
  end
end
