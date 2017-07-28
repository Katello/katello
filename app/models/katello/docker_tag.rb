module Katello
  class DockerTag < Katello::Model
    include Concerns::PulpDatabaseUnit
    include ScopedSearchExtensions
    belongs_to :docker_manifest, :inverse_of => :docker_tags, :class_name => "Katello::DockerManifest"
    belongs_to :repository, :inverse_of => :docker_tags, :class_name => "Katello::Repository"

    has_one :schema1_meta_tag, :class_name => "Katello::DockerMetaTag", :foreign_key => "schema1_id",
                               :inverse_of => :schema1, :dependent => :nullify

    has_one :schema2_meta_tag, :class_name => "Katello::DockerMetaTag", :foreign_key => "schema2_id",
                               :inverse_of => :schema2, :dependent => :nullify

    scoped_search :on => :name, :complete_value => true, :rename => :tag
    scoped_search :relation => :docker_manifest, :on => :name, :rename => :manifest,
      :complete_value => true, :only_explicit => false
    scoped_search :relation => :docker_manifest, :on => :digest, :rename => :digest,
      :complete_value => false, :only_explicit => true
    scoped_search :relation => :docker_manifest, :on => :schema_version, :rename => :schema_version,
      :complete_value => false, :only_explicit => true
    scoped_search :relation => :repository, :on => :name, :rename => :repository,
      :complete_value => true, :only_explicit => true

    scope :in_repositories, ->(repos) { where(:repository_id => repos) }

    delegate :relative_path, :environment, :content_view_version, :product, :to => :repository

    def self.grouped
      grouped_fields = "#{table_name}.name, #{Repository.table_name}.name, #{Product.table_name}.name"
      ids = uniq.select("ON (#{grouped_fields}) #{table_name}.id").joins(:repository => :product)
      where(:id => ids)
    end

    def update_from_json(json)
      self.docker_manifest_id ||= ::Katello::DockerManifest.find_by(:digest => json['manifest_digest']).try(:id)
      self.repository_id ||= ::Katello::Repository.find_by(:pulp_id => json['repo_id']).try(:id)
      self.name = json['name']
      self.save!
    end

    def self.import_all(uuids = nil, options = {})
      super
      if uuids
        repos = ::Katello::Repository.joins(:docker_tags).where("katello_docker_tags.uuid" => uuids).uniq
        ::Katello::DockerMetaTag.import_meta_tags(repos)
      else
        ::Katello::DockerMetaTag.import_meta_tags(::Katello::Repository.docker_type)
      end
    end

    def self.manage_repository_association
      false
    end

    # docker tag only has one repo
    def repositories
      [repository]
    end

    def full_name
      "#{docker_manifest.name}:#{name}"
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
  end
end
