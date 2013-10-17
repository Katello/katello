object @environment => :environment

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :prior_id, :library
node(:prior) { |e| e.prior.name if e.prior }

extends 'katello/api/v2/common/timestamps'
