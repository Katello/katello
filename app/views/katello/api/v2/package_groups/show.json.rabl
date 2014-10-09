object @resource

attributes :id
attributes :package_group_id
attributes :name
attributes :description
attributes :repo_id
attributes :default_package_names
attributes :mandatory_package_names
attributes :conditional_package_names
attributes :optional_package_names

node :repository do |package_group|
  if repo = Katello::Repository.where(:pulp_id => package_group.repo_id).first
    {
        :id => repo.id,
        :name => repo.name,
        :product => {
            :id => repo.product.id,
            :name => repo.product.name
        }
    }
  end
end
