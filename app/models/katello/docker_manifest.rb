module Katello
  class DockerManifest < Katello::Model
    include Concerns::PulpDatabaseUnit
    has_many :docker_tags, :as => :docker_taggable, :class_name => "Katello::DockerTag", :dependent => :destroy
    has_many :docker_manifest_list_manifests, :class_name => "Katello::DockerManifestListManifest",
             :dependent => :delete_all, :inverse_of => :docker_manifest
    has_many :docker_manifest_lists, :through => :docker_manifest_list_manifests, :inverse_of => :docker_manifests
    has_many :content_facets, :as => :manifest_entity
    has_many :hosts, :class_name => "::Host::Managed", :through => :content_facets, :inverse_of => :docker_manifests

    CONTENT_TYPE = "docker_manifest".freeze

    scope :bootable, -> { where(:is_bootable => true) }

    scoped_search :relation => :docker_tags, :on => :name, :rename => :tag, :complete_value => true
    scoped_search :on => :digest, :rename => :digest, :complete_value => true, :only_explicit => true
    scoped_search :on => :schema_version, :rename => :schema_version, :complete_value => true, :only_explicit => true
    scoped_search :relation => :docker_manifest_lists, :on => :digest, :rename => :manifest_list_digest, :complete_value => true, :only_explicit => true
    scoped_search :on => :is_bootable, :rename => :bootable, :complete_value => { true => true, false => false }, :only_explicit => true

    def self.default_sort
      order(:schema_version)
    end

    def manifest_type
      "image"
    end

    def remove_from_repository(repo_id)
      self.class.repository_association_class.where(:repository_id => repo_id, self.class.unit_id_field.to_sym => self.id).delete_all
      self.destroy if (self.repositories.empty? || self.docker_manifest_lists.empty?)
      DockerMetaTag.cleanup_tags
    end
  end
end
