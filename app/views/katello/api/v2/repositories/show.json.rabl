object @resource

extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'
extends 'katello/api/v2/repositories/base'

glue(@resource.root) do
  attributes :content_type
  attributes :docker_upstream_name
  attributes :docker_tags_whitelist
  attributes :mirror_on_sync, :verify_ssl_on_sync
  attributes :unprotected, :full_path, :checksum_type
  attributes :container_repository_name
  attributes :download_policy
  attributes :url
  attributes :ansible_collection_whitelist
  attributes :gpg_key_id
  attributes :ssl_ca_cert_id
  attributes :ssl_client_cert_id
  attributes :ssl_client_key_id

  attributes :product_type
  attributes :upstream_username
  attributes :ostree_upstream_sync_policy, :ostree_upstream_sync_depth
  attributes :compute_ostree_upstream_sync_depth => :computed_ostree_upstream_sync_depth
  attributes :deb_releases, :deb_components, :deb_architectures
  attributes :http_proxy_policy
  attributes :http_proxy_id

  node :http_proxy do
    attributes :id => @resource.root&.http_proxy_id, :name => @resource.root&.http_proxy&.name
  end

  attributes :ignorable_content
  attributes :description

  node :ssl_ca_cert do
    attributes :id => @resource.root&.ssl_ca_cert&.id, :name => @resource.root&.ssl_ca_cert&.name
  end

  node :ssl_client_cert do
    attributes :id => @resource.root&.ssl_client_cert&.id, :name => @resource.root&.ssl_client_cert&.name
  end

  node :ssl_client_key do
    attributes :id => @resource.root&.ssl_client_key&.id, :name => @resource.root&.ssl_client_key&.name
  end

  child :gpg_key do
    attributes :id, :name
  end
end

attributes :ostree_branch_names => :ostree_branches
attributes :relative_path
attributes :promoted? => :promoted
attributes :content_view_version_id, :library_instance_id

if @resource.is_a?(Katello::Repository)
  if @resource.distribution_version || @resource.distribution_arch || @resource.distribution_family || @resource.distribution_variant
    attributes :distribution_version
    attributes :distribution_arch
    attributes :distribution_bootable? => :distribution_bootable
    attributes :distribution_family
    attributes :distribution_variant
  end
end

node :permissions do |repo|
  {
    :deletable => repo.deletable?
  }
end

node :upstream_password_exists do |repo|
  repo.root.upstream_password.present?
end

node :upstream_auth_exists do |repo|
  repo.upstream_username.present? && repo.upstream_password.present?
end

if @object && @object.library_instance_id.nil?

  node :content_view_environments do |repository|
    Katello::RepositoryPresenter.new(repository).content_view_environments
  end

end

child :environment => :environment do |_repo|
  attribute :id, :registry_unauthenticated_pull
end
