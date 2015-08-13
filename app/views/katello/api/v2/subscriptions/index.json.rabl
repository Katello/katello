object false

extends 'katello/api/v2/common/org_reference'
extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends "katello/api/v2/subscriptions/base"
end
