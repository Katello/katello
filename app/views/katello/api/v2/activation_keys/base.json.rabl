extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'

attributes :id, :name, :description, :unlimited_hosts, :content_view_environment_labels

node :multi_content_view_environment do |ak|
  ak.multi_content_view_environment?
end

child :content_view_environments => :content_view_environments do
  node :content_view do |cvenv|
    {
      id: cvenv.content_view&.id,
      name: cvenv.content_view&.name,
      label: cvenv.content_view&.label,
      composite: cvenv.content_view&.composite,
      rolling: cvenv.content_view&.rolling,
      content_view_version: cvenv.content_view_version&.version,
      content_view_version_id: cvenv.content_view_version&.id,
      content_view_version_latest: cvenv.content_view_version&.latest?,
      content_view_default: cvenv.content_view&.default?,
      content_view_environment_id: cvenv.id,
    }
  end
  node :lifecycle_environment do |cvenv|
    {
      id: cvenv.lifecycle_environment&.id,
      name: cvenv.lifecycle_environment&.name,
      label: cvenv.lifecycle_environment&.label,
      lifecycle_environment_library: cvenv.lifecycle_environment&.library?,
    }
  end
  node :label do |cvenv|
    cvenv.label
  end
end

attributes :usage_count, :user_id, :max_hosts, :system_template_id, :release_version, :purpose_usage, :purpose_role

node :permissions do |activation_key|
  {
    :view_activation_keys => activation_key.readable?,
    :edit_activation_keys => activation_key.editable?,
    :destroy_activation_keys => activation_key.deletable?,
  }
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
