attribute :pulp_id, :name, :organization_id, :max_systems, :description, :total_systems

node :id do |group|
  group.id.to_i
end

extends "katello/api/v2/common/timestamps"

node :permissions do |group|
  {
      :deletable        => group.deletable?,
      :editable         => group.editable?,
      :systems_readable => group.systems_readable?,
      :system_editable  => group.systems_editable?
  }
end
