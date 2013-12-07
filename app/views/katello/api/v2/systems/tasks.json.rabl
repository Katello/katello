object false

extends "katello/api/v2/common/index"

node :results do
  partial("katello/api/v2/systems/task", :object => @collection[:records])
end
