module Katello
  class RepositoryDockerImage < Katello::Model
    self.include_root_in_json = false

    # Do not use active record callbacks in this join model.  Direct INSERTs and DELETEs are done
    belongs_to :repository, :inverse_of => :repository_docker_images, :class_name => 'Katello::Repository'
    belongs_to :docker_image, :inverse_of => :repository_docker_images
  end
end
