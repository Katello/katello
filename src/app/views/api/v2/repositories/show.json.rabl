object @repository

extends 'api/v2/common/identifier'
extends 'api/v2/common/org_reference'

attributes :feed, :arch, :relative_path, :major, :minor, :enabled, :package_count
attributes :gpg_key_name, :gpg_key_id
attributes :environment_product_id, :content_id, :content_view_version_id, :library_instance_id

extends 'api/v2/common/timestamps'
extends 'api/v2/common/syncable'
