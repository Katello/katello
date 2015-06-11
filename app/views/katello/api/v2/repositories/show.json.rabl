object @resource

extends 'katello/api/v2/common/org_reference'
extends 'katello/api/v2/common/timestamps'

attributes :content_type
attributes :docker_upstream_name
attributes :unprotected, :full_path, :checksum_type, :container_repository_name
attributes :url,
           :relative_path
extends 'katello/api/v2/repositories/base'

attributes :major, :minor
attributes :gpg_key_id
attributes :content_id, :content_view_version_id, :library_instance_id
attributes :product_type
attributes :promoted? => :promoted
attributes :ostree_branch_names => :ostree_branches

node :permissions do |repo|
  {
    :deletable => repo.deletable?
  }
end

child :gpg_key do |_gpg|
  attribute :name
  attribute :id
end

if @object && @object.library_instance_id.nil?

  node :content_view_environments do |repository|
    Katello::RepositoryPresenter.new(repository).content_view_environments
  end

end

child :environment => :environment do |_repo|
  attribute :id
end
