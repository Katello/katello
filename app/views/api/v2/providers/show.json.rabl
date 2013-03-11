object @provider

attributes :id, :name, :description, :provider_type, :organization_id
attributes :repository_url, :discovered_repos, :discovery_url

extends 'api/v2/common/syncable'
extends 'api/v2/common/timestamps'


