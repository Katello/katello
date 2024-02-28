object @resource

@resource ||= @object
@facet = @resource.content_facet

attributes :id, :name, :description

node :operatingsystem_family do |resource|
  resource.operatingsystem&.family
end

node :operatingsystem_major do |resource|
  resource.operatingsystem&.major
end

if @facet
  node :content_view do
    content_view = @facet&.single_content_view
    if content_view.present?
      {
        :id => content_view.id,
        :name => content_view.name,
        :composite => content_view.composite?
      }
    end
  end
  node :lifecycle_environment do
    lifecycle_environment = @facet&.single_lifecycle_environment
    if lifecycle_environment.present?
      {
        :id => lifecycle_environment.id,
        :name => lifecycle_environment.name
      }
    end
  end
end
