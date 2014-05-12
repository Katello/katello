object @environment => :environment

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :library

node :prior do |env|
  if env.prior
    {name: env.prior.name, :id => env.prior.id}
  else
    nil
  end

end

node :permissions do |env|
  {
    :readable => env.readable?,
    :editable => env.editable?,
    :deletable => env.deletable?
  }
end

extends 'katello/api/v2/common/timestamps'
