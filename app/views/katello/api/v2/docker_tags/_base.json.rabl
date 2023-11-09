object @resource

attributes :id, :name
attributes :repository_id

child :schema1_manifest => :manifest_schema1 do
  attributes :pulp_id => :id
  attributes :schema_version, :digest, :manifest_type
end

child :schema2_manifest => :manifest_schema2 do
  attributes :pulp_id => :id
  attributes :schema_version, :digest, :manifest_type
end

child :docker_manifest => :manifest do
  attributes :pulp_id => :id
  attributes :schema_version, :digest, :manifest_type
end

if @organization
  node :repositories do
    @object.repositories.in_organization(@organization).map do |repo|
      attributes = {
        :id => repo.id,
        :name => repo.name,
        :full_path => repo.full_path
      }
      attributes
    end
  end
  node :product do
    first_repo = @object.repositories.in_organization(@organization)&.first
    product = first_repo&.product
    attributes = {
      :id => product&.id,
      :name => product&.name
    }
    attributes
  end
else
  child :repositories => :repositories do
    attributes :id, :name, :full_path
  end

  child :product => :product do
    attributes :id, :name
  end
end

node :upstream_name do |item|
  item.upstream_name
end

child :environment => :environment do
  attributes :id, :name
end

child :content_view_version do
  attributes :id, :name, :content_view_id
end
