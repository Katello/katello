object @resource

attributes :katello_uuid => :id
attributes :size, :image_id

child :tags => :tags do
  attributes :repository_id, :tag
end
