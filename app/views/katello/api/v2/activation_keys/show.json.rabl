object @activation_key

extends 'katello/api/v2/common/identifier'

extends 'katello/api/v2/common/org_reference'

attributes :content_view, :content_view_id
child :environment => :environment do
  extends 'katello/api/v2/environments/show'
end
attributes :environment_id

attributes :usage_count, :user_id, :usage_limit, :pools, :system_template_id

node :permissions do |activation_key|
  {
    :editable => activation_key.class.manageable?(activation_key.organization)
  }
end

child :system_groups => :system_groups do
  attributes :id
  attributes :name
end

extends 'katello/api/v2/common/timestamps'
