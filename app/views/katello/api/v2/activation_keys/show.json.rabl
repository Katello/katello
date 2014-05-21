object @activation_key

attributes :id, :name
attributes :description

extends 'katello/api/v2/common/org_reference'

attributes :content_view, :content_view_id
child :environment => :environment do
  extends 'katello/api/v2/environments/show'
end
attributes :environment_id

attributes :usage_count, :user_id, :usage_limit, :pools, :system_template_id, :release_version,
           :service_level
attributes :get_key_pools => :pools

child :products => :products do |product|
  attributes :id, :name
end

node :permissions do |activation_key|
  {
    :editable => activation_key.editable?,
    :deletable => activation_key.deletable?
  }
end

child :host_collections => :host_collections do
  attributes :id
  attributes :name
end

attributes :content_overrides

extends 'katello/api/v2/common/timestamps'
