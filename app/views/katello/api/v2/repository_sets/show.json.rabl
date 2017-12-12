object @resource

@resource ||= @object

glue :content do
  node do |content|
    {
      id: content.cp_content_id,
      name: content.name,
      label: content.label,
      vendor: content.vendor,
      type: content.content_type,
      gpgUrl: content.gpg_url,
      contentUrl: content.content_url
    }
  end

  attributes :name, :vendor, :label
end
attribute :enabled

if @resource.product
  child :product => :product do
    attributes :id, :name
  end
end

child @resource.repositories => :repositories do
  attributes :id, :name, :arch
  attributes :minor => :releasever
end
