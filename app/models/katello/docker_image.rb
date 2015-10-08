module Katello
  class DockerImage < Katello::Model
    include Concerns::PulpDatabaseUnit

    has_many :docker_tags, :dependent => :destroy, :class_name => "Katello::DockerTag"
    has_many :repository_docker_images, :dependent => :destroy
    has_many :repositories, :through => :repository_docker_images, :inverse_of => :docker_images

    validates :image_id, presence: true, uniqueness: true

    CONTENT_TYPE = Pulp::DockerImage::CONTENT_TYPE
    scoped_search :on => :image_id, :rename => :name

    def self.repository_association_class
      RepositoryDockerImage
    end

    def update_from_json(json)
      update_attributes(:image_id => json[:image_id],
                        :size => json[:size]
                       )
    end
  end
end
