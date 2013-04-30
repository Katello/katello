object @environment => :environment

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'

attributes :prior_id, :library
node(:prior) { |e| e.prior.name if e.prior }

extends 'api/v2/common/timestamps'
