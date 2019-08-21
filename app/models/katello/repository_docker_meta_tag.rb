module Katello
  class RepositoryDockerMetaTag < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_docker_meta_tags, :class_name => 'Katello::Repository'
    belongs_to :docker_meta_tag, :inverse_of => :repository_docker_meta_tags, :class_name => 'Katello::DockerMetaTag'
  end
end
