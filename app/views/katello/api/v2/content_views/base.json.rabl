extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :composite
attributes :component_ids
attributes :default
attributes :version_count
attributes :latest_version, :latest_version_id
attributes :auto_publish
attributes :solve_dependencies
attributes :import_only
attributes :related_cv_count
attributes :related_composite_cvs

node :next_version do |content_view|
  content_view.next_version.to_f.to_s
end

child :last_task => :last_task do |_task|
  attributes :id, :started_at
  attributes :result => :result
  node :last_sync_words do |object|
    if object.try(:started_at)
      time_ago_in_words(Time.parse(object.started_at.to_s))
    end
  end
end

child :latest_version_env => :latest_version_environments do
  attributes :id, :name, :label
end

node :last_published do |content_view|
  unless content_view.versions.empty?
    content_view.versions.order(:created_at).last.created_at
  end
end

child :environments => :environments do
  attributes :id, :name, :label
  node :permissions do |env|
    {
      :readable => env.readable?
    }
  end
end

if @object.composite?
  child :component_repositories => :repositories do
    attributes :id, :name, :label, :content_type
  end
  attributes :component_repository_ids => :repository_ids
else
  child :repositories => :repositories do
    attributes :id, :name, :label, :content_type
  end
  attributes :repository_ids
end

child :versions => :versions do
  attributes :id, :version
  attributes :created_at => :published
  attributes :environment_ids
end

if params.key?(:include_permissions)
  node :permissions do |cv|
    {
      :view_content_views => cv.readable?,
      :edit_content_views => cv.editable?,
      :destroy_content_views => cv.deletable?,
      :publish_content_views => cv.publishable?,
      :promote_or_remove_content_views => cv.promotable_or_removable?
    }
  end
end

child :components => :components do
  attributes :id, :name, :label, :content_view_id, :version

  child :environments => :environments do
    attributes :id, :name, :label
  end

  child :content_view => :content_view do
    attributes :id, :name, :label, :description, :next_version, :latest_version
  end

  child :archived_repos => :repositories do
    attributes :id, :name, :label, :description
  end
end

child :content_view_components => :content_view_components do
  extends "katello/api/v2/content_view_components/show"
end

child :activation_keys => :activation_keys do
  attributes :id, :name
end

child :hosts => :hosts do
  attributes :id, :name
end

extends 'katello/api/v2/common/timestamps'
