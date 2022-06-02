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

node :osRestricted do |pc|
  pc.repositories&.first&.os_versions&.first
end

node :override do |pc|
  pc.override if pc.respond_to? :override
end

node :overrides do |pc|
  if pc.respond_to? :content_overrides
    pc.content_overrides.map do |override|
      {:name => override.name, :value => override.computed_value}
    end
  end
end

node :enabled_content_override do |pc|
  if pc.respond_to? :enabled_content_override
    override = pc.enabled_content_override
    override&.computed_value
  end
end

# ISSUE: this doesn't take into account the repo's arch or OS version restrictions
# It may be better to just make a new "bound repositories" API endpoint...
# REMOVE ME
if params[:host_id].present?
  node :enabled_for_host do |pc|
    if pc.enabled_content_override.present?
      pc.enabled_content_override.computed_value
    else
      host = ::Host.find(params[:host_id].to_i)
      if host.organization.simple_content_access?
        true
      else
        ::Katello::ProductContentFinder.new(consumable: host.subscription_facet, match_subscription: true).product_content.find { |host_pc| host_pc.attributes == pc.attributes }.present?
      end
    end
  end
end
