module Katello
  class DockerManifest < Katello::Model
    include Concerns::PulpDatabaseUnit

    has_many :docker_tags, :dependent => :destroy, :class_name => "Katello::DockerTag", :foreign_key => :docker_manifest_id
    has_many :repository_docker_manifests, :dependent => :destroy
    has_many :repositories, :through => :repository_docker_manifests, :inverse_of => :docker_manifests

    CONTENT_TYPE = Pulp::DockerManifest::CONTENT_TYPE
    scoped_search :on => :name, :complete_value => true
    scoped_search :relation => :docker_tags, :on => :name, :rename => :tag, :complete_value => true, :only_explicit => true
    scoped_search :on => :digest, :rename => :digest, :complete_value => true, :only_explicit => true
    scoped_search :on => :schema_version, :rename => :schema_version, :complete_value => true, :only_explicit => true

    def self.repository_association_class
      RepositoryDockerManifest
    end

    def update_from_json(json)
      update_attributes(:name => json[:name],
                        :schema_version => json[:schema_version],
                        :digest => json[:digest],
                        :downloaded => json[:downloaded]
                       )
    end

    def self.default_sort
      order(:name).order(:schema_version)
    end
  end
end
