object @resource

extends 'katello/api/v2/docker_tags/base'

child :docker_image => :image do
  attributes :uuid => :id
  attributes :image_id
end

child :related_tags => :related_tags do
  attributes :id, :name
end
