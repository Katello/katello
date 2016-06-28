object false

extends 'katello/api/v2/common/org_reference'
extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  attributes :quantity_attached
  extends "katello/api/v2/subscriptions/base"
end
