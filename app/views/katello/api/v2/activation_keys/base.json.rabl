extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'

attributes :id, :name, :description, :unlimited_hosts, :auto_attach, :content_view_environment_labels

node :multi_content_view_environment do |ak|
  ak.multi_content_view_environment?
end

child :content_view_environments => :content_view_environments do
  node :content_view do |cve|
    {
      id: cve.content_view&.id,
      name: cve.content_view&.name,
      composite: cve.content_view&.composite,
      content_view_version: cve.content_view_version&.version,
      content_view_version_id: cve.content_view_version&.id,
      content_view_version_latest: cve.content_view_version&.latest?,
      content_view_default: cve.content_view&.default?,
      content_view_environment_id: cve.id,
    }
  end
  node :lifecycle_environment do |cve|
    {
      id: cve.lifecycle_environment&.id,
      name: cve.lifecycle_environment&.name,
      lifecycle_environment_library: cve.lifecycle_environment&.library?,
    }
  end
  node :label do |cve|
    cve.label
  end
end

# single cv/lce for backward compatibility
node :content_view_id do |ak|
  ak.single_content_view&.id
end

node :content_view do |ak|
  ak.single_content_view&.slice(:id, :name)
end

node :environment_id do |ak|
  ak.single_lifecycle_environment&.id
end

node :environment do |ak|
  ak.single_lifecycle_environment&.slice(:id, :name)
end

attributes :usage_count, :user_id, :max_hosts, :system_template_id, :release_version, :purpose_usage, :purpose_role

node :purpose_addons do |key|
  key.purpose_addons.pluck(:name)
end

node :permissions do |activation_key|
  {
    :view_activation_keys => activation_key.readable?,
    :edit_activation_keys => activation_key.editable?,
    :destroy_activation_keys => activation_key.deletable?,
  }
end

child :products => :products do |_product|
  attributes :id, :name
end

if ::Foreman::Cast.to_bool(params.fetch(:show_hosts, false))
  child :hosts do
    attributes :id, :name
  end
end

child :host_collections => :host_collections do
  attributes :id
  attributes :name
end
