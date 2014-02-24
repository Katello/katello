object @resource

extends 'katello/api/v2/common/identifier'

attributes :version

child :content_view => :content_view do
  attributes :id, :name, :label
end

extends 'katello/api/v2/common/timestamps'

child :environments => :environments do
  attributes :id, :name, :label
end

child :active_history => :active_history do
  attributes :id
  attributes :katello_environment_id => :environment_id
end
