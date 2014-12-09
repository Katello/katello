object @resource

attributes :id, :name
attributes :repository_id

child :docker_image => :image do
  attributes :uuid => :id
  attributes :image_id
end

child :repository => :repository do
  attributes :id, :name
end
