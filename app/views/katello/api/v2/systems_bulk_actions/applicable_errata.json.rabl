object false

extends "katello/api/v2/common/metadata"

node :results do
    partial("katello/api/v2/systems_bulk_actions/erratum", :object => @collection[:results])
end
