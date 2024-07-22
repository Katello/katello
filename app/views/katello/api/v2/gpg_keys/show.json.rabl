object @resource

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'

attributes :name
attributes :content

child :products => :products do
  attributes :id, :cp_id, :name
  node :repository_count do |product|
    product.repositories.count
  end
  child :provider => :provider do
    attribute :name
    attribute :id
  end
end

child :repositories => :repositories do
  attribute :id
  attribute :name
  attribute :content_type

  child :product do |_product|
    attributes :id, :cp_id, :name
  end
end

node :permissions do |gpg_key|
  {
    :view_gpg_keys => gpg_key.readable?,
    :edit_gpg_keys => gpg_key.editable?,
    :destroy_gpg_keys => gpg_key.deletable?,
  }
end
