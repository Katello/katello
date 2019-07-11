module Katello
  # rubocop:disable Metrics/ClassLength
  class ContentView < Katello::Model
    audited :associations => [:repositories, :environments]
    has_associated_audits
    include Ext::LabelFromName
    include Katello::Authorization::ContentView
    include ForemanTasks::Concerns::ActionSubject

    CONTENT_DIR = "content_views".freeze

    belongs_to :organization, :inverse_of => :content_views, :class_name => "::Organization"

    has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment", :dependent => :destroy
    has_many :environments, :class_name => "Katello::KTEnvironment", :through => :content_view_environments

    has_many :content_view_versions, :class_name => "Katello::ContentViewVersion", :dependent => :destroy
    alias_method :versions, :content_view_versions

    # Note the difference between content_view_components and component_composites both refer to
    # ContentViewComponent but mean different things.
    # content_view_components -> Topdown, given I am a composite CV get the associated components belonging to me
    #
    # component_composites -> Bottom Up, given I am a component CV get the associated composites that I belong to
    #
    has_many :content_view_components, :class_name => "Katello::ContentViewComponent", :dependent => :destroy,
             :inverse_of => :composite_content_view, :foreign_key => :composite_content_view_id, autosave: true

    has_many :component_composites, :class_name => "Katello::ContentViewComponent",
             :dependent => :destroy, :inverse_of => :content_view, :foreign_key => :content_view_id

    has_many :content_view_repositories, :class_name => 'Katello::ContentViewRepository',
             :dependent => :destroy, :inverse_of => :content_view
    has_many :repositories, :through => :content_view_repositories, :class_name => "Katello::Repository",
                            :after_remove => :remove_repository

    has_many :content_view_puppet_modules, :class_name => "Katello::ContentViewPuppetModule",
                                           :dependent => :destroy
    alias_method :puppet_modules, :content_view_puppet_modules

    has_many :filters, :dependent => :destroy, :class_name => "Katello::ContentViewFilter"

    has_many :activation_keys, :class_name => "Katello::ActivationKey", :dependent => :restrict_with_exception

    has_many :content_facets, :class_name => "Katello::Host::ContentFacet", :foreign_key => :content_view_id,
                          :inverse_of => :content_view, :dependent => :restrict_with_exception
    has_many :hosts,      :class_name => "::Host::Managed", :through => :content_facets,
                          :inverse_of => :content_view
    has_many :hostgroups, :class_name => "::Hostgroup", :foreign_key => :content_view_id,
                          :inverse_of => :content_view, :dependent => :nullify

    has_many :repository_references, :class_name => 'Katello::Pulp3::RepositoryReference', :foreign_key => :content_view_id,
             :dependent => :destroy, :inverse_of => :content_view

    validates_lengths_from_database :except => [:label]
    validates :label, :uniqueness => {:scope => :organization_id},
                      :presence => true
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
    validates :organization_id, :presence => true
    validate :check_non_composite_components
    validate :check_puppet_conflicts
    validate :check_docker_conflicts
    validate :check_non_composite_auto_publish
    validates :composite, :inclusion => [true, false]
    validates :composite,
              inclusion: { in: [false], message: "Composite Content Views can not solve dependencies"},
              if: :solve_dependencies

    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label

    scope :default, -> { where(:default => true) }
    scope :non_default, -> { where(:default => false) }
    scope :composite, -> { where(:composite => true) }
    scope :non_composite, -> { where(:composite => [nil, false]) }

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :label, :complete_value => true
    scoped_search :on => :composite, :complete_value => {true: true, false: false}

    def self.in_environment(env)
      joins(:content_view_environments).
        where("#{Katello::ContentViewEnvironment.table_name}.environment_id = ?", env.id)
    end

    def to_s
      name
    end

    def content_host_count
      hosts.count
    end

    def component_ids
      components.map(&:id)
    end

    def components
      content_view_components.map(&:latest_version).compact.freeze
    end

    # Adds content view components based on the input
    # [{:content_view_version_id=>1, :latest=> false}, {:content_view_id=>1, :latest=> true} ..]
    def add_components(components_to_add)
      components_to_add.each do |cvc|
        content_view_components.build(cvc)
      end
    end

    # Removes selected content view components
    # [1,2,34] => content view component ids/
    def remove_components(components_to_remove)
      content_view_components.where(:id => components_to_remove).destroy_all
    end

    # Warning this call wipes out existing associations
    # And replaces them with the component version ids passed in.
    def component_ids=(component_version_ids_to_set)
      content_view_components.destroy_all
      component_version_ids_to_set.each do |content_view_version_id|
        cvv = ContentViewVersion.find(content_view_version_id)
        content_view_components.build(:content_view_version => cvv,
                                      :latest => false,
                                      :composite_content_view => self)
      end
    end

    def copy_components(new_view)
      self.content_view_components.each do |cvc|
        component = cvc.dup
        component.composite_content_view = new_view
        new_view.content_view_components << component
      end
    end

    def copy_filters(new_view)
      self.filters.each do |filter|
        new_filter = filter.dup
        new_filter.repositories = filter.repositories
        new_view.filters << new_filter

        case filter.type
        when ContentViewPackageFilter.name
          filter.package_rules.each do |rule|
            new_filter.package_rules << rule.dup
          end
        when ContentViewPackageGroupFilter.name
          filter.package_group_rules.each do |rule|
            new_filter.package_group_rules << rule.dup
          end
        when ContentViewErratumFilter.name
          filter.erratum_rules.each do |rule|
            new_filter.erratum_rules << rule.dup
          end
        end
      end
    end

    def copy(new_name)
      new_view = ContentView.new
      new_view.name = new_name
      new_view.attributes = self.attributes.slice("description", "organization_id", "default", "composite", "solve_dependencies")
      new_view.save!
      new_view.repositories = self.repositories

      copy_components(new_view)

      self.content_view_puppet_modules.each do |puppet_module|
        new_view.content_view_puppet_modules << puppet_module.dup
      end
      copy_filters(new_view)
      new_view.save!
      new_view
    end

    def publish_puppet_environment?
      force_puppet_environment? || puppet_modules.any? || component_modules_to_publish.present?
    end

    def promoted?
      # if the view exists in more than 1 environment, it has been promoted
      self.environments.many?
    end

    #NOTE: this function will most likely become obsolete once we drop api v1
    def as_json(options = {})
      result = self.attributes
      result['organization'] = self.organization.try(:name)
      result['environments'] = environments.map { |e| e.try(:name) }
      result['versions'] = versions.map(&:version)
      result['versions_details'] = versions.map do |v|
        {
          :version => v.version,
          :published => v.created_at.to_s,
          :environments => v.environments.map { |e| e.name }
        }
      end

      if options && options[:environment].present?
        result['repositories'] = repos(options[:environment]).map(&:name)
      end

      result
    end

    def total_package_count(env)
      Katello::Rpm.in_repositories(self.repos(env)).count
    end

    def total_deb_package_count(env)
      Katello::Deb.in_repositories(self.repos(env)).count
    end

    def total_puppet_module_count(env)
      repoids = self.repos(env).collect { |r| r.pulp_id }
      result = Katello::PuppetModule.legacy_search('*', :page_size => 1, :repoids => repoids)
      result.length > 0 ? result.total : 0
    end

    def in_environment?(env)
      environments.include?(env)
    end

    def version(env)
      self.versions.in_environment(env).order("#{Katello::ContentViewVersion.table_name}.id ASC").readonly(false).last
    end

    def latest_version
      latest_version_object.try(:version)
    end

    def latest_version_object
      self.versions.order('major DESC').order('minor DESC').first
    end

    def history
      Katello::ContentViewHistory.joins(:content_view_version).where(
          "#{Katello::ContentViewVersion.table_name}.content_view_id" => self.id)
    end

    def version_environment(env)
      # TODO: rewrite this into SQL or use content_view_environment when that
      # points to environment
      version(env).content_view_version_environments.select { |cvve| cvve.environment_id == env.id }
    end

    def resulting_products
      (self.repositories.collect { |r| r.product }).uniq
    end

    def puppet_repos
      # These are the repos that may contain puppet modules that can be associated with the content view
      self.organization.library.repositories.puppet_type
    end

    def repos(env = nil)
      if env
        repo_ids = versions.flat_map { |version| version.repositories.in_environment(env) }.map(&:id)
      else
        repo_ids = versions.flat_map { |version| version.repositories }.map(&:id)
      end
      Repository.where(:id => repo_ids)
    end

    def puppet_env(env)
      if env
        ids = versions.flat_map { |version| version.content_view_puppet_environments.in_environment(env) }.map(&:id)
      else
        ids = []
      end
      ContentViewPuppetEnvironment.where(:id => ids).first
    end

    def library_repos
      Repository.where(:id => library_repo_ids)
    end

    def library_repo_ids
      repos(self.organization.library).map { |r| r.library_instance_id }
    end

    def all_version_repos
      Repository.joins(:content_view_version).
        where("#{Katello::ContentViewVersion.table_name}.content_view_id" => self.id)
    end

    def repositories_to_publish
      if composite?
        ids = components.flat_map { |version| version.repositories.archived }.map(&:id)
        Repository.where(:id => ids)
      else
        repositories
      end
    end

    def repositories_to_publish_ids
      composite? ? repositories_to_publish.pluck(&:id) : repository_ids
    end

    def repositories_to_publish_by_library_instance
      # retrieve the list of repositories in a hash, where the key
      # is the library instance id, and the value is an array
      # of the repositories for that instance.
      repositories_to_publish.inject({}) do |result, repo|
        result[repo.library_instance] ||= []
        result[repo.library_instance] << repo
        result
      end
    end

    def duplicate_repositories_to_publish
      return [] unless composite?
      repositories_to_publish_by_library_instance.select { |key, val| val.count > 1 && key.present? }.keys
    end

    def components_with_repo(library_instance)
      components.select { |component| component.repositories.where(:library_instance => library_instance).any? }
    end

    def auto_publish_components
      component_composites.where(latest: true).joins(:composite_content_view).where(self.class.table_name => {auto_publish: true})
    end

    def publish_repositories
      repositories = composite? ? repositories_to_publish_by_library_instance.values : repositories_to_publish
      repositories.each do |repos|
        if repos.is_a? Array
          yield repos
        else
          yield [repos]
        end
      end
    end

    # Returns actual puppet modules associated with all components
    def component_modules_to_publish
      composite? ? components.flat_map { |version| version.puppet_modules } : nil
    end

    # Returns the content view puppet modules associated with the content view
    #
    # @returns array of ContentViewPuppetModule
    def puppet_modules_to_publish
      composite? ? nil : content_view_puppet_modules
    end

    def component_repositories
      components.map(&:archived_repos).flatten
    end

    def component_repository_ids
      component_repositories.map(&:id)
    end

    def repos_in_product(env, product)
      version = version(env)
      if version
        version.repositories.in_environment(env).in_product(product)
      else
        []
      end
    end

    def products(env = nil)
      repos = repos(env)
      Product.joins(:repositories).where("#{Katello::Repository.table_name}.id" => repos.map(&:id)).distinct
    end

    #get the library instances of all repos within this view
    def all_version_library_instances
      all_repos = all_version_repos.where(:library_instance_id => nil).pluck("#{Katello::Repository.table_name}.id")
      all_repos += all_version_repos.pluck(:library_instance_id)
      Repository.where(:id => all_repos)
    end

    def get_repo_clone(env, repo)
      lib_id = repo.library_instance_id || repo.id
      Repository.in_environment(env).where(:library_instance_id => lib_id).
          joins(:content_view_version).
          where("#{Katello::ContentViewVersion.table_name}.content_view_id" => self.id)
    end

    def delete(from_env)
      if from_env.library? && in_non_library_environment?
        fail Errors::ChangesetContentException, _("Cannot delete view while it exists in environments")
      end

      version = self.version(from_env)
      if version.nil?
        fail Errors::ChangesetContentException, _("Cannot delete from %s, view does not exist there.") % from_env.name
      end
      version = ContentViewVersion.find(version.id)

      if (foreman_env = Environment.find_by_katello_id(self.organization, from_env, self))
        foreman_env.destroy
      end

      version.delete(from_env)
      self.destroy if self.versions.empty?
    end

    def in_non_library_environment?
      environments.where(:library => false).length > 0
    end

    def duplicate_repositories
      counts = repositories_to_publish.each_with_object(Hash.new(0)) do |repo, h|
        h[repo.library_instance_id] += 1
      end
      ids = counts.select { |_k, v| v > 1 }.keys
      Repository.where(:id => ids)
    end

    def duplicate_puppet_modules
      modules = puppet_modules_to_publish || component_modules_to_publish
      counts = modules.each_with_object(Hash.new(0)) do |puppet_module, h|
        h[puppet_module.name] += 1
      end
      counts.select { |_k, v| v > 1 }.keys
    end

    def duplicate_docker_repos
      duplicate_repositories.docker_type
    end

    def check_non_composite_components
      if !composite? && components.present?
        errors.add(:base, _("Cannot add component versions to a non-composite content view"))
      end
    end

    def check_non_composite_auto_publish
      if !composite? && auto_publish
        errors.add(:base, _("Cannot set auto publish to a non-composite content view"))
      end
    end

    def check_puppet_conflicts
      duplicate_puppet_modules.each do |name|
        versions = components.select { |v| v.puppet_modules.map(&:name).include?(name) }
        names = versions.map(&:name).join(", ")
        msg = _("Puppet module conflict: '%{mod}' is in %{versions}.") % {mod: name, versions: names}
        errors.add(:base, msg)
      end
    end

    def check_docker_conflicts
      duplicate_docker_repos.each do |repo|
        msg = _("Container Image repo '%{repo}' is present in multiple component content views.") % {repo: repo.name}
        errors.add(:base, msg)
      end
    end

    def content_view_environment(environment)
      self.content_view_environments.where(:environment_id => environment.try(:id)).first
    end

    def update_cp_content(env)
      view_env = content_view_environment(env)
      view_env.update_cp_content if view_env
    end

    # Associate an environment with this content view.  This can occur whenever
    # a version of the view is promoted to an environment.  It is necessary for
    # candlepin to become aware that the view is available for consumers.
    def add_environment(env, version)
      if self.content_view_environments.where(:environment_id => env.id).empty?
        label = generate_cp_environment_label(env)
        ContentViewEnvironment.create!(:name => label,
                                       :label => label,
                                       :cp_id => generate_cp_environment_id(env),
                                       :environment_id => env.id,
                                       :content_view => self,
                                       :content_view_version => version
                                      )
      end
    end

    # Unassociate an environment from this content view. This can occur whenever
    # a view is deleted from an environment. It is necessary to make candlepin
    # aware that the view is no longer available for consumers.
    def remove_environment(env)
      # Do not remove the content view environment, if there is still a view
      # version in the environment.
      if self.versions.in_environment(env).blank?
        view_env = self.content_view_environments.where(:environment_id => env.id)
        view_env.first.destroy unless view_env.blank?
      end
    end

    def cp_environment_label(env)
      ContentViewEnvironment.where(:content_view_id => self, :environment_id => env).first.try(:label)
    end

    def cp_environment_id(env)
      ContentViewEnvironment.where(:content_view_id => self, :environment_id => env).first.try(:cp_id)
    end

    def create_new_version(major = next_version, minor = 0, components = self.components)
      version = ContentViewVersion.create!(:major => major,
                                           :minor => minor,
                                           :content_view => self,
                                           :components => components
                                          )

      update_attributes(:next_version => major.to_i + 1) unless major.to_i < next_version
      version
    end

    def build_puppet_env(options)
      if options[:environment] && options[:version]
        fail "Cannot create into both an environment and a content view version archive"
      end

      to_env       = options[:environment]
      version      = options[:version]
      content_view = self
      to_version   = version || content_view.version(to_env)

      ContentViewPuppetEnvironment.new(
        :environment => to_env,
        :content_view_version => to_version,
        :name => self.name
      )
    end

    def create_puppet_env(options)
      build_puppet_env(options).save!
    end

    def computed_modules_by_repoid
      names_and_authors = []
      puppet_modules = []

      if composite?
        puppet_modules = component_modules_to_publish
      else
        puppet_modules_to_publish.each do |cvpm|
          if cvpm.uuid
            puppet_modules << cvpm.puppet_module
          else
            names_and_authors << { :name => cvpm.name, :author => cvpm.author }
          end
        end
      end

      if names_and_authors.present?
        names_and_authors.each do |name_and_author|
          puppet_module = ::Katello::PuppetModule.latest_module(
            name_and_author[:name],
            name_and_author[:author],
            self.organization.library.repositories.puppet_type
          )
          puppet_modules << puppet_module if puppet_module
        end
      end

      # In order to minimize the number of copy requests, organize the data by repoid.
      PuppetModule.group_by_repoid(puppet_modules.flatten)
    end

    def check_ready_to_publish!
      fail _("User must be logged in.") if ::User.current.nil?
      fail _("Cannot publish default content view") if default?
      check_composite_action_allowed!(organization.library)
      check_docker_repository_names!([organization.library])
      true
    end

    def check_docker_repository_names!(environments)
      environments.each do |environment|
        repositories = []
        publish_repositories do |all_repositories|
          repositories += all_repositories.keep_if { |repository| repository.content_type == Katello::Repository::DOCKER_TYPE }
        end
        next if repositories.empty?

        error_messages = ::Katello::Validators::EnvironmentDockerRepositoriesValidator.validate_repositories(environment.registry_name_pattern, repositories)
        unless error_messages.empty?
          error_messages << _("Consider changing the Lifecycle Environment's Registry Name Pattern to something more specific.")
          fail error_messages.join("  ")
        end
      end
      true
    end

    def check_composite_action_allowed!(env)
      if composite? && Setting['restrict_composite_view']
        if components.size != content_view_components.size
          fail _("Make sure all the component content views are published before publishing/promoting the composite content view. "\
               "This restriction is optional and can be modified in the Administrator -> Settings -> Content "\
                "page using the restrict_composite_view flag.")
        end

        env_ids = env.try(:pluck, 'id') || []
        env_ids << env.id unless env_ids.size > 0
        components.each do |component|
          component_environment_ids = component.environments.pluck('id')
          unless (env_ids - component_environment_ids).empty?
            fail _("The action requested on this composite view cannot be performed until all of the "\
                   "component content view versions have been promoted to the target environment: %{env}.  "\
                   "This restriction is optional and can be modified in the Administrator -> Settings -> Content "\
                   "page using the restrict_composite_view flag.") %
                   { :env => env.try(:pluck, 'name') || env.name }
          end
        end
      end
      true
    end

    def check_remove_from_environment!(env)
      errors = []

      dependencies = {hosts: _("hosts"),
                      activation_keys: _("activation keys")
      }

      dependencies.each do |key, name|
        if (models = self.association(key).scope.in_environment(env)).any?
          errors << _("Cannot remove '%{view}' from environment '%{env}' due to associated %{dependent}: %{names}.") %
            {view: self.name, env: env.name, dependent: name, names: models.map(&:name).join(", ")}
        end
      end

      fail errors.join(" ") if errors.any?
      return true
    end

    def check_ready_to_destroy!
      errors = []

      dependencies = {environments: _("environments"),
                      hosts: _("hosts"),
                      activation_keys: _("activation keys")
      }

      dependencies.each do |key, name|
        if (models = self.association(key).scope).any?
          errors << _("Cannot delete '%{view}' due to associated %{dependent}: %{names}.") %
            {view: self.name, dependent: name, names: models.map(&:name).join(", ")}
        end
      end

      fail errors.join(" ") if errors.any?
      return true
    end

    def self.humanize_class_name(_name = nil)
      _("Content Views")
    end

    def version_count
      content_view_versions.count
    end

    def on_demand_repositories
      repositories.on_demand
    end

    protected

    def remove_repository(repository)
      filters.each do |filter_item|
        repo_exists = Repository.unscoped.joins(:filters).where(
            ContentViewFilter.table_name => {:id => filter_item.id}, :id => repository.id).count
        if repo_exists
          filter_item.repositories.delete(repository)
          filter_item.save!
        end
      end
    end

    private

    def generate_cp_environment_label(env)
      # The label for a default view, will simply be the env label; otherwise, it
      # will be a combination of env and view label.  The reason being, the label
      # for a default view is internally generated (e.g. 'Default_View_for_dev')
      # and we do not need to expose it to the user.
      self.default ? env.label : [env.label, self.label].join('/')
    end

    def generate_cp_environment_id(env)
      # The id for a default view, will simply be the org label; otherwise, it
      # will be a combination of env id and view id.  The reason being,
      # for a default view, the same candlepin environment will be referenced
      # by the kt_environment and content_view_environment.
      value = self.default ? env.organization.label.to_s : [env.organization.label, env.label, self.label].join('-')
      Katello::Util::Data.hexdigest(value)
    end

    def confirm_not_promoted
      if promoted?
        errors.add(:base, _("cannot be deleted if it has been promoted."))
        return false
      end
      return true
    end

    def related_resources
      self.organization
    end

    class Jail < ::Safemode::Jail
      allow :name, :label
    end
  end
end
