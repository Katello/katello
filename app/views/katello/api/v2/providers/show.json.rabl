object @provider

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'

attributes :provider_type
attributes :repository_url, :discovered_repos, :discovery_url

extends 'api/v2/common/syncable'
extends 'api/v2/common/timestamps'


