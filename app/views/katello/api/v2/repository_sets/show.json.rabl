object @resource => :repository_set

attribute :katello_enabled? => :katello_enabled

glue :content do
  extends 'api/v2/common/identifier'
  attributes :type, :updated, :vendor, :gpgUrl, :contentUrl
end


