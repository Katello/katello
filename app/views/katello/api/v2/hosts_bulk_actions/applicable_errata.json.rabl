object false

extends "katello/api/v2/common/metadata"

node :results do
  partial("katello/api/v2/hosts_bulk_actions/applicable_erratum", :object => @collection[:results])
end
