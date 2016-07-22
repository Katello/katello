object @resource
extends 'katello/api/v2/common/identifier'

extends 'katello/api/v2/common/timestamps'

attributes :latest
child :composite_content_view => :composite_content_view do
  attributes :id, :name, :label, :description, :next_version, :latest_version, :version_count
end

child :content_view => :content_view do
  attributes :id, :name, :label, :description, :next_version, :latest_version, :version_count
end

child :latest_version => :content_view_version do
  attributes :id, :name, :label, :content_view_id, :version, :puppet_module_count

  child :content_view => :content_view do
    attributes :id, :name, :label, :description
  end

  child :environments => :environments do
    attributes :id, :name, :label
  end

  child :archived_repos => :repositories do
    attributes :id, :name, :label, :description
  end
end
