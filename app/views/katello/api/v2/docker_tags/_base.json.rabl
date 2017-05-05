object @resource

attributes :id, :name, :full_name
attributes :repository_id

child :schema1_manifest => :manifest_schema1 do
  attributes :uuid => :id
  attributes :name, :schema_version, :digest
end

child :schema2_manifest => :manifest_schema2 do
  attributes :uuid => :id
  attributes :name, :schema_version, :digest
end

child :docker_manifest => :manifest do
  attributes :uuid => :id
  attributes :name, :schema_version, :digest
end

child :repository => :repository do
  attributes :id, :name, :full_path
end

child :product => :product do
  attributes :id, :name
end

child :environment => :environment do
  attributes :id, :name
end

child :content_view_version do
  attributes :id, :name, :content_view_id
end
