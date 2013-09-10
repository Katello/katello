object @resource

attributes :id
attributes :name
attributes :label
attributes :description

extends 'api/v2/common/org_reference'

attributes :provider_type

extends 'api/v2/common/readonly'
extends 'api/v2/common/timestamps'
