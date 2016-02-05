module Katello
  class DockerTag < Katello::Model
    include ScopedSearchExtensions
    belongs_to :docker_manifest, :inverse_of => :docker_tag
    belongs_to :repository, :inverse_of => :docker_tags, :class_name => "Katello::Repository"

    validates :name, presence: true, uniqueness: {scope: :repository_id}
    validates :docker_manifest, presence: true

    scoped_search :on => :name, :complete_value => true
    scoped_search :in => :docker_manifest, :on => :name, :rename => :manifest,
      :complete_value => true, :only_explicit => true
    scoped_search :in => :repository, :on => :name, :rename => :repository,
      :complete_value => true, :only_explicit => true

    scope :in_repositories, ->(repos) { where(:repository_id => repos) }

    delegate :relative_path, :environment, :content_view_version, :product, :to => :repository

    def self.grouped
      grouped_fields = "#{table_name}.name, #{Repository.table_name}.name, #{Product.table_name}.name"
      ids = uniq.select("ON (#{grouped_fields}) #{table_name}.id").joins(:repository => :product)
      where(:id => ids)
    end

    # docker tag doesn't have a uuid in pulp
    def self.with_uuid(uuid)
      where(:id => uuid)
    end

    # docker tag only has one repo
    def repositories
      [repository]
    end

    def full_name
      "#{repository.name}:#{name}"
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
