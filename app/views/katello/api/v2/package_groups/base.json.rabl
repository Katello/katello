object @resource

attributes :id
attributes :name
attributes :pulp_id
attributes :pulp_id => :uuid
attributes :description

node :repository do |package_group|
  if (repo = package_group.repository)
    {
      :id => repo.id,
      :name => repo.name,
      :product => {
        :id => repo.product.id,
        :name => repo.product.name,
      },
    }
  end
end
