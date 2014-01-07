object @resource

extends "katello/api/v2/providers/provider"

attributes :id
attributes :name
attributes :label
attributes :description
attributes :repository_url
attributes :owner_imports
attributes :rules_version
attributes :rules_source

extends 'katello/api/v2/common/org_reference'

attributes :provider_type

extends 'katello/api/v2/common/readonly'
extends 'katello/api/v2/common/timestamps'
