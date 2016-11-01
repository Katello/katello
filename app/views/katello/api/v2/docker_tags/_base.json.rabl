object @resource

attributes :id, :name, :full_name
attributes :repository_id, :manifest_id

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
