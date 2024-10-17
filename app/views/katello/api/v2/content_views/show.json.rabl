object @resource

extends "katello/api/v2/content_views/base"

attributes :content_host_count

node :errors do
  unless @resource.valid?
    attribute :messages => @resource.errors.full_messages
  end
end

child :duplicate_repositories_to_publish => :duplicate_repositories_to_publish do
  attributes :id, :name
  node :components do |repo|
    @resource.components_with_repo(repo).map do |component|
      {
        :content_view_name => component.content_view.name,
        :content_view_version => component.version
      }
    end
  end
end
