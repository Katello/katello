extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'

attributes :id, :name, :description, :unlimited_hosts, :auto_attach

attributes :content_view_id

child :content_view => :content_view do
  attributes :id, :name
end

child :environment => :environment do
  attributes :name, :id
end
attributes :environment_id

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
