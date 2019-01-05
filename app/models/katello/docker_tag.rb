module Katello
  class DockerTag < Katello::Model
    include Concerns::PulpDatabaseUnit
    include ScopedSearchExtensions
    belongs_to :docker_taggable, :polymorphic => true, :inverse_of => :docker_tags
    belongs_to :repository, :inverse_of => :docker_tags, :class_name => "Katello::Repository"

    has_one :schema1_meta_tag, :class_name => "Katello::DockerMetaTag", :foreign_key => "schema1_id",
                               :inverse_of => :schema1, :dependent => :nullify

    has_one :schema2_meta_tag, :class_name => "Katello::DockerMetaTag", :foreign_key => "schema2_id",
                               :inverse_of => :schema2, :dependent => :nullify

    before_destroy :cleanup_meta_tags

    delegate :relative_path, :environment, :content_view_version, :product, :to => :repository

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

    def self.grouped
      grouped_fields = "#{table_name}.name, #{Repository.table_name}.root_id, #{Product.table_name}.name"
      ids = distinct.select("ON (#{grouped_fields}) #{table_name}.id").joins(:repository => :product)
      where(:id => ids)
    end

    def update_from_json(json)
      taggable_class = json['manifest_type'] == "list" ? ::Katello::DockerManifestList : ::Katello::DockerManifest
      self.docker_taggable = taggable_class.find_by(:digest => json['manifest_digest'])
      self.repository_id = ::Katello::Repository.find_by(:pulp_id => json['repo_id']).try(:id)
      self.name = json['name']
      self.save!
    end

    def self.import_all(uuids = nil, options = {})
      ::Katello::DockerTag.destroy_all if uuids.blank?
      super
      ::Katello::DockerTag.where(:repository_id => nil).destroy_all
      if uuids
        repos = ::Katello::Repository.joins(:docker_tags).where("katello_docker_tags.uuid" => uuids).distinct
        ::Katello::DockerMetaTag.import_meta_tags(repos)
      else
        ::Katello::DockerMetaTag.import_meta_tags(::Katello::Repository.docker_type)
      end
    end

    def self.import_for_repository(repository)
      ::Katello::DockerTag.where(:repository_id => repository).destroy_all
      super(repository, true)
    end

    def self.manage_repository_association
      false
    end

    # docker tag only has one repo
    def repositories
      [repository]
    end

    def related_tags
      # tags in the same repo group with the same name
      self.class.where(:repository_id => repository.group, :name => name)
    end

    def self.with_identifiers(ids)
      self.where(:id => ids)
    end

    def self.completer_scope_options
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
