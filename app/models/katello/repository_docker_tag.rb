module Katello
  class RepositoryDockerTag < Katello::Model
    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_docker_tags, :class_name => 'Katello::Repository'
    belongs_to :docker_tag, :inverse_of => :repository_docker_tags, :class_name => 'Katello::DockerTag'
  end
end
