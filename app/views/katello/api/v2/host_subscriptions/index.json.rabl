object false

extends "katello/api/v2/common/metadata"

child @collection[:results] => :results do
  extends "katello/api/v2/subscriptions/base"
  attribute :quantity_consumed
end
