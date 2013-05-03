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
  attributes :display_name, :errata_id, :changeset_id, :id
  node :product_id do |err|
    err.product.cp_id
  end
end

child :packages => :packages do
  attributes :id, :nvrea, :product_id, :package_id, :display_name
  node :product_id do |pkg|
    pkg.product.cp_id
  end
end

child :distributions => :distributions do
  attributes :id
  node :product_id do |err|
    err.product.cp_id
  end
end

child :content_views => :content_views do
  attributes :id, :name, :label
end

