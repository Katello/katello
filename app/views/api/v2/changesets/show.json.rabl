object @changeset => :changeset

extends 'api/v2/common/identifier'
extends 'api/v2/common/timestamps'

attributes :environment_id, :state, :task_status_id
attributes :promotion_date => :promoted_at
attributes :action_type => :type

child :products => :products do
  attributes :id, :name, :label
end

child :repos => :repositories do
  attributes :id, :name, :label
end

child :errata => :errata do
  attributes :product_id, :display_name, :errata_id, :changeset_id, :id
end

child :packages => :packages do
  attributes :id, :nvrea, :product_id, :package_id, :display_name
end

child :distributions => :distributions do
  attributes :id, :family, :variant, :version, :arch
end

child :system_templates => :system_templates do
  attributes :id, :name
end

child :content_views => :content_views do
  attributes :id, :name, :label
end

