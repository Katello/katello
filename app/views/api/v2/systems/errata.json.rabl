object false

extends "/api/v2/common/index"

node :results do
    partial("/api/v2/systems/erratum", :object => @collection[:records])
end
