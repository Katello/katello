object @resource

extends 'katello/api/v2/docker_tags/base'

child :related_tags => :related_tags do
  attributes :id, :name
end
