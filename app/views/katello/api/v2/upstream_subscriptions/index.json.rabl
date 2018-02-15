object false

extends "katello/api/v2/common/metadata"

node(:organization_id) { @organization.id }

child @collection[:results] => :results do
  extends "katello/api/v2/upstream_subscriptions/base"
end
