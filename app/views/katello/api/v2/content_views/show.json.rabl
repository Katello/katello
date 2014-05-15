object @resource

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :composite
attributes :repository_ids
attributes :component_ids
attributes :default
attributes :next_version

node :last_published do |content_view|
  if !content_view.versions.empty?
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
  extends 'katello/api/v2/repositories/show'
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
  :promotable_or_deletable => cv.promotable? && Katello::KTEnvironment.any_promotable?
}
end

child :components => :components do
  extends 'katello/api/v2/content_view_versions/show'
end

extends 'katello/api/v2/common/timestamps'
