object @resource

extends 'katello/api/v2/module_streams/base'

child :artifacts => :artifacts do
  attributes :id, :name
end

child :profiles => :profiles do
  attributes :id, :name
  child :rpms => :rpms do
    attributes :id, :name
  end
end

child :library_repositories => :repositories do
  attributes :id, :name
  glue :product do
    attributes :id => :product_id, :name => :product_name
  end
end
