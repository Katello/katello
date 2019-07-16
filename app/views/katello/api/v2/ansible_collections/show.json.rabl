object @resource

extends "katello/api/v2/ansible_collections/base"

child :library_repositories => :repositories do
  attributes :id, :name
  glue :product do
    attributes :id => :product_id, :name => :product_name
  end
end
