object @resource

@resource ||= @object

glue :content do
  extends 'katello/api/v2/common/identifier'
  attributes :type, :updated, :vendor, :gpgUrl, :contentUrl, :label
end
attribute :enabled

if @resource.product
  child :product => :product do
    attributes :id, :name
  end
end

child @resource.repositories => :repositories do
  attributes :id, :name
end
