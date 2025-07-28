extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/flatpak_remotes/permissions'

attributes :name
attributes :url, :description, :username, :seeded, :registry_url
