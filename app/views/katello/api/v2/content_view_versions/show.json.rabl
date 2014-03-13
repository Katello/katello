object @resource

extends 'katello/api/v2/common/identifier'

attributes :version
attributes :composite_content_view_ids
attributes :content_view_id

child :content_view => :content_view do
  extends 'katello/api/v2/content_views/show'
end

child :composite_content_views do
  attributes :id, :name, :label
end

extends 'katello/api/v2/common/timestamps'

child :environments => :environments do
  attributes :id, :name, :label
end

child :repositories => :repositories do
  attributes :id, :name, :label
end

child :active_history => :active_history do
  attributes :id
  attributes :katello_environment_id => :environment_id
end
