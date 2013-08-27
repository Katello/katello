object @repository

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'

attributes :feed, :relative_path, :major, :minor, :enabled, :package_count
attributes :gpg_key_name, :gpg_key_id
attributes :environment_product_id, :content_id, :content_view_version_id, :library_instance_id
attributes :product_id

child :architecture do |r|
  attribute :name
end

extends 'katello/api/v2/common/timestamps'
extends 'katello/api/v2/common/syncable'
