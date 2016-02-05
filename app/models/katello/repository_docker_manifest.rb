module Katello
  class RepositoryDockerManifest < Katello::Model
    self.include_root_in_json = false

    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_docker_manifests, :class_name => 'Katello::Repository'
    belongs_to :docker_manifest, :inverse_of => :repository_docker_manifests
  end
end
