object @provider

attributes :id
attributes :name
attributes :label
attributes :description

extends 'api/v2/common/org_reference'

attributes :provider_type
attributes :repository_url, :discovered_repos, :discovery_url

extends 'api/v2/common/syncable'
extends 'api/v2/common/timestamps'
