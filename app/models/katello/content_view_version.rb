module Katello
  class ContentViewVersion < Katello::Model
    include Authorization::ContentViewVersion
    include ForemanTasks::Concerns::ActionSubject
    include Katello::Concerns::SearchByRepositoryName

    define_model_callbacks :promote, :only => [:before, :after]
    audited :associations => [:repositories, :environments]
    before_destroy :validate_destroyable!

    belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :content_view_versions
    has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment",
                                         :dependent => :destroy
    has_many :environments, :through      => :content_view_environments,
                            :class_name   => "Katello::KTEnvironment",
                            :inverse_of   => :content_view_versions,
                            :after_remove => :remove_environment

    has_many :history, :class_name => "Katello::ContentViewHistory", :inverse_of => :content_view_version,
                       :dependent => :destroy, :foreign_key => :katello_content_view_version_id

    has_many :triggered_histories, :class_name => "Katello::ContentViewHistory", :dependent => :destroy,
             :inverse_of => :triggered_by, :foreign_key => :triggered_by_id

    has_many :repositories, :class_name => "Katello::Repository", :dependent => :destroy
    has_many :content_view_puppet_environments, :class_name => "Katello::ContentViewPuppetEnvironment",
                                                :dependent => :destroy
    has_one :task_status, :class_name => "Katello::TaskStatus", :as => :task_owner, :dependent => :destroy

    has_many :content_view_components, :class_name => "Katello::ContentViewComponent",
             :inverse_of => :content_view_version, :dependent => :destroy
    has_many :composite_content_views, :through => :content_view_components, :source => :composite_content_view

    has_many :content_view_version_components, :inverse_of => :composite_version, :dependent => :destroy, :foreign_key => :composite_version_id,
             :class_name => "Katello::ContentViewVersionComponent"
    has_many :components, :through => :content_view_version_components, :source => :component_version,
             :class_name => "Katello::ContentViewVersion", :inverse_of => :composites

    has_many :content_view_version_composites, :inverse_of => :component_version, :dependent => :destroy, :foreign_key => :component_version_id,
             :class_name => "Katello::ContentViewVersionComponent"
    has_many :composites, :through => :content_view_version_composites, :source => :composite_version,
             :class_name => "Katello::ContentViewVersion", :inverse_of => :components
    has_many :published_in_composite_content_views, through: :composites, source: :content_view

    delegate :default, :default?, to: :content_view

    validates_lengths_from_database

    validates :minor, :uniqueness => {:scope => [:content_view_id, :major], :message => N_(", must be unique to major and version id version.")}
    validates :minor, numericality: true

    scope :default_view, -> { joins(:content_view).where("#{Katello::ContentView.table_name}.default" => true) }
    scope :non_default_view, -> { joins(:content_view).where("#{Katello::ContentView.table_name}.default" => false) }
    scope :with_organization_id, ->(organization_id) do
      joins(:content_view).where("#{Katello::ContentView.table_name}.organization_id" => organization_id)
    end

    scope :triggered_by, ->(content_view_version_id) do
      sql = Katello::ContentViewHistory.where(:triggered_by_id => content_view_version_id).select(:katello_content_view_version_id).to_sql
      where("#{Katello::ContentViewVersion.table_name}.id in (#{sql})")
    end

    scoped_search :on => :content_view_id, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :major, :rename => :version, :complete_value => true, :ext_method => :find_by_version
    serialize :content_counts

    def self.find_by_version(_key, operator, value)
      conditions = ""
      if ['>', '<', '=', '<=', '>=', "<>", "!=", 'IN', 'NOT IN'].include?(operator) && value.to_f >= 0
        major, minor = value.split(".")
        case
        when /[<>]/ =~ operator
          minor ||= 0
          query = where("major #{operator} :major OR (major = :major AND minor #{operator} :minor)", :major => major, :minor => minor)
        when minor.nil?
          query = where("major #{operator} (:major)", :major => major)
        else
          query = where("major #{operator} (:major) and minor #{operator} (:minor)", :major => major, :minor => minor)
        end
        _, conditions = query.to_sql.split("WHERE")
      end
      { :conditions => conditions }
    end

    def self.component_of(versions)
      joins(:content_view_version_composites).where("#{Katello::ContentViewVersionComponent.table_name}.composite_version_id" => versions)
    end

    def self.with_library_repo(repo)
      joins(:repositories).where("#{Katello::Repository.table_name}.library_instance_id" => repo)
    end

    def self.for_version(version)
      major, minor = version.to_s.split('.')
      minor ||= 0
      query = where(:major => major, :minor => minor)
      query
    end

    def self.with_puppet_module(puppet_module)
      joins(:content_view_puppet_environments)
        .where("#{Katello::ContentViewPuppetEnvironment.table_name}.id" => puppet_module.content_view_puppet_environments)
    end

    def to_s
      name
    end

    delegate :organization, to: :content_view

    def active_history
      self.history.select { |history| history.task.try(:pending) }
    end

    def last_event
      self.history.order(:created_at).last
    end

    def name
      "#{content_view} #{version}"
    end

    def description
      history.publish.successful.first.try(:notes)
    end

    def default_content_view?
      default?
    end

    def in_composite?
      composite_content_views.any?
    end

    def published_in_composite?
      content_view_version_composites.any?
    end

    def in_environment?
      environments.any?
    end

    def available_releases
      Katello::RootRepository.where(:id => self.repositories.select(:root_id)).pluck(:minor).compact.uniq.sort
    end

    def next_incremental_version
      "#{major}.#{minor + 1}"
    end

    def version
      "#{major}.#{minor}"
    end

    def repos(env)
      self.repositories.in_environment(env)
    end

    def puppet_env(env)
      self.content_view_puppet_environments.in_environment(env).first
    end

    def promote_puppet_environment?
      (!content_counts.blank? && content_counts.dig(PuppetModule::CONTENT_TYPE) > 0) || self.content_view.force_puppet_environment?
    end

    def archived_repos
      self.default? ? self.repositories : self.repos(nil)
    end

    def non_archive_repos
      self.repositories.non_archived
    end

    def library_repos
      archived_repos.includes(:library_instance).map(&:library_instance)
    end

    def products(env = nil)
      if env
        repos(env).map(&:product).uniq(&:id)
      else
        self.repositories.map(&:product).uniq(&:id)
      end
    end

    def repos_ordered_by_product(env)
      # The repository model has a default scope that orders repositories by name;
      # however, for content views, it is desirable to order the repositories
      # based on the name of the product the repository is part of.
      Repository.send(:with_exclusive_scope) do
        self.repositories.joins(:product).in_environment(env).order("#{Katello::Product.table_name}.name asc")
      end
    end

    def get_repo_clone(env, repo)
      lib_id = repo.library_instance_id || repo.id
      self.repos(env).where("#{Katello::Repository.table_name}.library_instance_id" => lib_id)
    end

    def self.in_environment(env)
      joins(:content_view_environments).where("#{Katello::ContentViewEnvironment.table_name}.environment_id" => env)
    end

    def removable?
      if environments.blank?
        content_view.promotable_or_removable?
      else
        content_view.promotable_or_removable? && KTEnvironment.where(:id => environments).any_promotable?
      end
    end

    def deletable?(from_env)
      ::Host.in_content_view_environment(self.content_view, from_env).empty? ||
          self.content_view.versions.in_environment(from_env).count > 1
    end

    def promotable?(target_envs)
      target_envs = Array.wrap(target_envs)
      all_environments = target_envs + environments
      target_envs.all? do |environment|
        all_environments.include?(environment.prior) || environments.empty? && environment == organization.library
      end
    end

    def archive_puppet_environment
      content_view_puppet_environments.archived.first
    end

    def puppet_modules
      if archive_puppet_environment
        archive_puppet_environment.puppet_modules
      else
        []
      end
    end

    def components_needing_errata(errata)
      component_repos = Repository.where(:content_view_version_id => self.components)
      library_repos = Repository.where(:id => component_repos.pluck(:library_instance_id)).with_errata(errata)
      component_repos -= component_repos.with_errata(errata) #find component repos without the errata
      component_repos.select { |repo| library_repos.include?(repo.library_instance) }.map(&:content_view_version).uniq
    end

    def packages
      Rpm.in_repositories(archived_repos)
    end

    def library_packages
      Rpm.in_repositories(library_repos)
    end

    def available_packages
      library_packages.where.not(:id => packages)
    end

    def srpms
      Katello::Srpm.in_repositories(self.repositories)
    end

    def module_streams
      ModuleStream.in_repositories(archived_repos)
    end

    def docker_tags
      # Don't count tags from non-archived repos; this causes count errors
      ::Katello::DockerMetaTag.where(:id => RepositoryDockerMetaTag.where(:repository_id => repositories.archived.docker_type).select(:docker_meta_tag_id))
    end

    def debs
      Katello::Deb.in_repositories(self.repositories.archived)
    end

    def errata(errata_type = nil)
      errata = Erratum.in_repositories(archived_repos)
      errata = errata.of_type(errata_type) if errata_type
      errata
    end

    def library_errata
      Erratum.in_repositories(library_repos)
    end

    def available_errata
      library_errata.where.not(:id => errata)
    end

    def file_units
      FileUnit.in_repositories(archived_repos)
    end

    def ostree_branches
      OstreeBranch.in_repositories(archived_repos)
    end

    def docker_manifests
      DockerManifest.in_repositories(archived_repos)
    end

    def docker_manifest_lists
      DockerManifestList.in_repositories(archived_repos)
    end

    def package_groups
      PackageGroup.in_repositories(archived_repos)
    end

    def update_content_counts!
      self.content_counts = {}
      RepositoryTypeManager.indexable_content_types.map(&:model_class).each do |content_type|
        if content_type::CONTENT_TYPE == DockerTag::CONTENT_TYPE
          content_counts[DockerTag::CONTENT_TYPE] = docker_tags.count
        else
          content_counts[content_type::CONTENT_TYPE] = content_type.in_repositories(self.repositories.archived).count
        end
      end
      save!
    end

    def content_counts_map
      return {} if content_counts.blank?
      counts = Hash[content_counts.map { |key, value| ["#{key}_count", value] }]
      counts.merge("module_stream_count" => counts["modulemd_count"],
                   "package_count" => counts["rpm_count"],
                   "ostree_branch_count" => counts["ostree_count"])
    end

    def check_ready_to_promote!(to_env)
      fail _("Default content view versions cannot be promoted") if default?
      content_view.check_composite_action_allowed!(to_env)
      content_view.check_docker_repository_names!(to_env)
    end

    def validate_destroyable!(skip_environment_check = false)
      unless organization.being_deleted?
        if !skip_environment_check && in_environment?
          fail _("Cannot delete version while it is in environments: %s") %
                   environments.map(&:name).join(",")
        end

        if in_composite?
          fail _("Cannot delete version while it is in use by composite content views: %s") %
                   composite_content_views.map(&:name).join(",")
        end

        if published_in_composite?
          list = composites.map do |version|
            "#{version.content_view.name} Version #{version.version}"
          end
          fail _("Cannot delete version while it is in use by composite content views: %s") %
                   list.join(",")
        end
      end
      true
    end

    def before_promote_hooks
      run_callbacks :sync do
        logger.debug "custom hook before_promote on #{name} will be executed if defined."
        true
      end
    end

    def after_promote_hooks
      run_callbacks :sync do
        logger.debug "custom hook after_promote on #{name} will be executed if defined."
        true
      end
    end

    def rabl_path
      "katello/api/v2/#{self.class.to_s.demodulize.tableize}/show"
    end

    private

    def remove_environment(env)
      content_view.remove_environment(env) unless content_view.content_view_versions.in_environment(env).count > 1
    end

    def related_resources
      [self.content_view]
    end

    class Jail < ::Safemode::Jail
      allow :name, :label, :version
    end
  end
end
