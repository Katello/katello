object @resource

attributes :id
attributes :name
attributes :label
attributes :description

extends 'katello/api/v2/common/org_reference'

attributes :provider_type

extends 'katello/api/v2/common/readonly'
extends 'katello/api/v2/common/timestamps'
