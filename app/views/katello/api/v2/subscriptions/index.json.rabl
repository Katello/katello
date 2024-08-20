object false

extends 'katello/api/v2/common/org_reference'
extends "katello/api/v2/common/metadata"
extends 'katello/api/v2/subscriptions/permissions'

child @collection[:results] => :results do
  attributes :quantity_attached
  attributes :product_host_count
  extends "katello/api/v2/subscriptions/base"
end
