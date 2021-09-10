object @resource

extends "katello/api/v2/generic_content_units/base"

child :library_repositories => :repositories do
  attributes :id, :name
  glue :product do
    attributes :id => :product_id, :name => :product_name
  end
end
