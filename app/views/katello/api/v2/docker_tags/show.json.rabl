object @resource

attributes :id, :tag

child :image => :image do
  attributes :katello_uuid => :id
  attributes :image_id
end

child :repository => :repository do
  attributes :id, :name
end
