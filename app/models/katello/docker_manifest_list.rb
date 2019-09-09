module Katello
  class DockerManifestList < Katello::Model
    include Concerns::PulpDatabaseUnit

    has_many :docker_tags, :as => :docker_taggable, :class_name => "Katello::DockerTag", :dependent => :destroy
    has_many :docker_manifest_list_manifests, :class_name => "Katello::DockerManifestListManifest",
             :dependent => :delete_all, :inverse_of => :docker_manifest_list
    has_many :docker_manifests, :through => :docker_manifest_list_manifests, :inverse_of => :docker_manifest_lists

    CONTENT_TYPE = "docker_manifest_list".freeze

    scoped_search :relation => :docker_tags, :on => :name, :rename => :tag, :complete_value => true
    scoped_search :on => :digest, :rename => :digest, :complete_value => true, :only_explicit => true
    scoped_search :on => :schema_version, :rename => :schema_version, :complete_value => true, :only_explicit => true

    def self.default_sort
      order(:schema_version)
    end

    def manifest_type
      "list"
    end
  end
end
