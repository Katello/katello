extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :composite
attributes :repository_ids
attributes :component_ids
attributes :default
attributes :next_version

node :last_published do |content_view|
  unless content_view.versions.empty?
    content_view.versions.last.created_at
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

child :repositories => :repositories do
  attributes :id, :name, :label, :content_type
end

child :puppet_modules => :puppet_modules do
  attributes :id, :name, :author, :uuid
  attributes :created_at
  attributes :updated_at
end

child :versions => :versions do
  attributes :id, :version
  attributes :created_at => :published
  attributes :environment_ids
end

node :permissions do |cv|
  {
    :view_content_views => cv.readable?,
    :edit_content_views => cv.editable?,
    :destroy_content_views => cv.deletable?,
    :publish_content_views => cv.publishable?,
    :promote_or_remove_content_views => cv.promotable_or_removable?
  }
end

child :components => :components do
  extends 'katello/api/v2/content_view_versions/show'
end

child :activation_keys => :activation_keys do
  attributes :id, :name
end

extends 'katello/api/v2/common/timestamps'
