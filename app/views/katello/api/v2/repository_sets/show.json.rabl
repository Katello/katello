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

# For backwards compatibility with the original
# ActivationKeys#product_contents

child :content => :content do
  attributes :id, :name, :label, :vendor, :content_type, :content_url, :gpg_url
end

child @resource.repositories => :repositories do
  attributes :id, :name, :arch
  attributes :minor => :releasever
end

node :override do |pc|
  pc.override
end

node :overrides do |pc|
  pc.content_overrides.map do |override|
    {:name => override.name, :value => override.computed_value}
  end
end

node :enabled_content_override do |pc|
  override = pc.enabled_content_override
  override&.computed_value
end
