module Types
  class HostCollection < BaseObject
    description "A collection of hosts"
    model_class ::Katello::HostCollection

    global_id_field :id
    timestamps
    field :name, String
    field :description, String
    field :max_hosts, Integer
    field :unlimited_hosts, Boolean
    has_many :hosts, Types::Host

    def self.graphql_definition
      super.tap { |type| type.instance_variable_set(:@name, 'Katello::HostCollection') }
    end
  end
end
