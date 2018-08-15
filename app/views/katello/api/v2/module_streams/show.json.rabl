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
