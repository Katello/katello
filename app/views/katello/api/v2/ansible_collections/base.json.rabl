object @resource

attributes :id
attributes :name
attributes :namespace
attributes :version
attributes :checksum
attributes :description

node :tags do |collection|
  collection.tags.map(&:name)
end
