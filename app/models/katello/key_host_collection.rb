module Katello
  class KeyHostCollection < Katello::Model
    belongs_to :activation_key, :inverse_of => :key_host_collections, :class_name => "Katello::ActivationKey"
    belongs_to :host_collection, :inverse_of => :key_host_collections, :class_name => "Katello::HostCollection"
    validates_lengths_from_database
  end
end
