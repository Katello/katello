attribute :pulp_id, :name, :organization_id, :max_systems, :description, :total_systems

node :id do |group|
  group.id.to_i
end

extends "/api/v2/common/timestamps"

