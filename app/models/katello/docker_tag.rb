module Katello
  class DockerTag < Katello::Model
    include Concerns::PulpDatabaseUnit
    include ScopedSearchExtensions

    CONTENT_TYPE = 'docker_tag'.freeze

    belongs_to :docker_taggable, :polymorphic => true, :inverse_of => :docker_tags
    has_one :schema1_meta_tag, :class_name => "Katello::DockerMetaTag", :foreign_key => "schema1_id",
                               :inverse_of => :schema1, :dependent => :nullify

    has_one :schema2_meta_tag, :class_name => "Katello::DockerMetaTag", :foreign_key => "schema2_id",
                               :inverse_of => :schema2, :dependent => :nullify

    before_destroy :cleanup_meta_tags

    def repository
      repositories.first
    end

    def relative_path
      repositories.first.relative_path
    end

    def environment
      repositories.first.environment
    end

    def content_view_version
      repositories.first.content_view_version
    end

    def product
      repositories.first.product
    end

    def associated_meta_tag
      schema1_meta_tag || schema2_meta_tag
    end

    def associated_meta_tag_identifier
      associated_meta_tag.try(:id)
    end

    def docker_manifest
      docker_taggable
    end

    def docker_manifest_id
      docker_taggable_id
    end

    def docker_manifest_list
      docker_taggable
    end

    def docker_manifest_list_id
      docker_taggable_id
    end

    def self.import_for_repository(repository, options = {})
      super(repository, options)
      ::Katello::DockerMetaTag.import_meta_tags([repository])
    end

    def related_tags
      # tags in the same repo group with the same name
      self.class.where(:id => RepositoryDockerTag.where(:repository_id => repositories.first.group).select(:docker_tag_id),
                       :name => name)
    end

    def self.with_identifiers(ids)
      self.where(:id => ids)
    end

    def self.completer_scope_options(_search)
      {"#{Katello::Repository.table_name}" => lambda { |repo_class| repo_class.docker_type } }
    end

    def cleanup_meta_tags
      if schema1_meta_tag && schema1_meta_tag.schema2.blank?
        schema1_meta_tag.destroy
      end

      if schema2_meta_tag && schema2_meta_tag.schema1.blank?
        schema2_meta_tag.destroy
      end
    end
  end
end
