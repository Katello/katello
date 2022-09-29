object @resource

@resource ||= @object
@facet = @resource.content_facet

attributes :id, :name, :description
if @facet
  node :content_view do
    if @facet.single_content_view_environment?
      content_view = @facet.single_content_view
      {
        :id => content_view.id,
        :name => content_view.name,
        :composite => content_view.composite?
      }
    else
      "multiple"
    end
  end
  node :lifecycle_environment do
    if @facet.single_content_view_environment?
      lifecycle_environment = @facet.single_lifecycle_environment
      {
        :id => lifecycle_environment.id,
        :name => lifecycle_environment.name
      }
    else
      "multiple"
    end
  end
end
