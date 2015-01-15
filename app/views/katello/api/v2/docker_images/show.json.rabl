object @resource

attributes :uuid => :id
attributes :size, :image_id

child :docker_tags => :tags do
  attributes :repository_id
  attributes :name
end
