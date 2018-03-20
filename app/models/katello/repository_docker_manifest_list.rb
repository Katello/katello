module Katello
  class RepositoryDockerManifestList < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_docker_manifest_lists, :class_name => 'Katello::Repository'
    belongs_to :docker_manifest_list, :inverse_of => :repository_docker_manifest_lists, :class_name => 'Katello::DockerManifestList'
  end
end
