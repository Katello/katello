child :content_facet => :content do
  extends 'katello/api/v2/content_facet/base'

  node do |content_facet|
    version = content_facet.content_view_version
    {
      :content_view_version => version.version,
      :content_view_version_id => version.id
    }
  end
end
