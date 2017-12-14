object @resource

extends 'katello/api/v2/common/identifier'
extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'

attributes :name
attributes :content_type
attributes :content

child :products => :gpg_key_products do
  attributes :id, :cp_id, :name
  node :repository_count do |product|
    product.repositories.count
  end
  child :provider => :provider do
    attribute :name
    attribute :id
  end
end

child :repositories => :gpg_key_repos do
  attribute :id
  attribute :name
  attribute :content_type

  child :product do |_product|
    attributes :id, :cp_id, :name
  end
end

child :ssl_ca_products => :ssl_ca_products do
  attributes :id, :cp_id, :name
  node :repository_count do |product|
    product.repositories.count
  end
  child :provider => :provider do
    attribute :name
    attribute :id
  end
end

child :ssl_ca_repos => :ssl_ca_repos do
  attribute :id
  attribute :name
  attribute :content_type

  child :product do |_product|
    attributes :id, :cp_id, :name
  end
end

child :ssl_client_products => :ssl_client_products do
  attributes :id, :cp_id, :name
  node :repository_count do |product|
    product.repositories.count
  end
  child :provider => :provider do
    attribute :name
    attribute :id
  end
end

child :ssl_client_repos => :ssl_client_repos do
  attribute :id
  attribute :name
  attribute :content_type

  child :product do |_product|
    attributes :id, :cp_id, :name
  end
end

child :ssl_key_products => :ssl_key_products do
  attributes :id, :cp_id, :name
  node :repository_count do |product|
    product.repositories.count
  end
  child :provider => :provider do
    attribute :name
    attribute :id
  end
end

child :ssl_key_repos => :ssl_key_repos do
  attribute :id
  attribute :name
  attribute :content_type

  child :product do |_product|
    attributes :id, :cp_id, :name
  end
end

node :permissions do |content_credential|
  {
    :view_content_credenials => content_credential.readable?,
    :edit_content_credenials => content_credential.editable?,
    :destroy_content_credenials => content_credential.deletable?
  }
end
