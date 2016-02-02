child :content_facet => :content do
  extends 'katello/api/v2/content_facet/base'

  node do |content_facet|
    version = content_facet.content_view_version
    {
      :content_view_version => version.version,
      :content_view_version_id => version.id
    }
  end

  node :content_view_default? do |content_facet|
    content_facet.content_view.default?
  end

  node :lifecycle_environment_library? do |content_facet|
    content_facet.lifecycle_environment.library?
  end
end

child :host_collections => :host_collections do
  attributes :id, :name
end

attributes :description, :facts
