object @resource

extends 'katello/api/v2/common/identifier'

attributes :version

child :content_view => :content_view do
  attributes :id, :name, :label
end

extends 'katello/api/v2/common/timestamps'
