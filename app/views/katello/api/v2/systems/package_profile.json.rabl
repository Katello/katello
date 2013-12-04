object false

extends "katello/api/v2/common/index"

node :results do
    partial("katello/api/v2/systems/package", :object => @collection[:records])
end
