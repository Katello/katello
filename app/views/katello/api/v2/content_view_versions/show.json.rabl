object @resource

extends 'katello/api/v2/common/identifier'

attributes :version
attributes :composite_content_view_ids
attributes :content_view_id
attributes :default
attributes :package_count, :errata_count

attributes :errata_type_counts => :errata_counts

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

child :archived_repos => :repositories do
  attributes :id, :name, :label
end

child :active_history => :active_history do
  extends 'katello/api/v2/content_view_histories/show'
end

child :puppet_modules => :puppet_modules do
  attributes :id
  attributes :name
  attributes :author
  attributes :version
end
