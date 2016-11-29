module Katello
  class DockerTag < Katello::Model
    include Concerns::PulpDatabaseUnit
    include ScopedSearchExtensions
    belongs_to :docker_manifest, :inverse_of => :docker_tags
    belongs_to :repository, :inverse_of => :docker_tags, :class_name => "Katello::Repository"

    scoped_search :on => :name, :complete_value => true, :rename => :tag
    scoped_search :in => :docker_manifest, :on => :name, :rename => :manifest,
      :complete_value => true, :only_explicit => false
    scoped_search :in => :docker_manifest, :on => :digest, :rename => :digest,
      :complete_value => false, :only_explicit => true
    scoped_search :in => :repository, :on => :name, :rename => :repository,
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
