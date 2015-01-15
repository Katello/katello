object @resource

attributes :uuid => :id
attributes :size, :image_id

child :tags => :tags do
  attributes :katello_repository_id => :repository_id
  attributes :tag
end
