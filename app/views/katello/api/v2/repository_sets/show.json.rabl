object @resource

@resource ||= @object

attribute :katello_enabled? => :katello_enabled

glue :content do
  extends 'katello/api/v2/common/identifier'
  attributes :type, :updated, :vendor, :gpgUrl, :contentUrl
end

child @resource.repositories => :repositories do
    attributes :id, :name, :enabled
end
