module Katello
  class ContentView < Katello::Model
    self.include_root_in_json = false

    include Ext::LabelFromName
    include Katello::Authorization::ContentView
    include ForemanTasks::Concerns::ActionSubject

    CONTENT_DIR = "content_views".freeze

    belongs_to :organization, :inverse_of => :content_views, :class_name => "::Organization"

    has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment", :dependent => :destroy
    has_many :environments, :class_name => "Katello::KTEnvironment", :through => :content_view_environments

    has_many :content_view_versions, :class_name => "Katello::ContentViewVersion", :dependent => :destroy
    alias_method :versions, :content_view_versions

    has_many :content_view_components, :class_name => "Katello::ContentViewComponent", :dependent => :destroy
    has_many :components, :through => :content_view_components, :class_name => "Katello::ContentViewVersion",
                          :source => :content_view_version do
      def <<(*_args)
        # this doesn't go through validation and generate a nice error message
        fail "Adding components without doing validation is not supported"
      end
    end

    has_many :content_view_repositories, :dependent => :destroy, :inverse_of => :content_view
    has_many :repositories, :through => :content_view_repositories, :class_name => "Katello::Repository",
                            :after_remove => :remove_repository

    has_many :content_view_puppet_modules, :class_name => "Katello::ContentViewPuppetModule",
                                           :dependent => :destroy
    alias_method :puppet_modules, :content_view_puppet_modules

    has_many :filters, :dependent => :destroy, :class_name => "Katello::ContentViewFilter"

    has_many :activation_keys, :class_name => "Katello::ActivationKey", :dependent => :restrict_with_exception
    has_many :systems, :class_name => "Katello::System", :dependent => :restrict_with_exception

    has_many :content_facets, :class_name => "Katello::Host::ContentFacet", :foreign_key => :content_view_id,
                          :inverse_of => :content_view, :dependent => :restrict_with_exception
    has_many :hosts,      :class_name => "::Host::Managed", :through => :content_facets,
                          :inverse_of => :content_view
    has_many :hostgroups, :class_name => "::Hostgroup", :foreign_key => :content_view_id,
                          :inverse_of => :content_view, :dependent => :restrict_with_exception

    validates_lengths_from_database :except => [:label]
    validates :label, :uniqueness => {:scope => :organization_id},
                      :presence => true
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id}
    validates :organization_id, :presence => true
    validate :check_repo_conflicts
    validate :check_puppet_conflicts
    validates :composite, :inclusion => [true, false]

    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label

    scope :default, -> { where(:default => true) }
    scope :non_default, -> { where(:default => false) }
    scope :composite, -> { where(:composite => true) }
    scope :non_composite, -> { where(:composite => [nil, false]) }

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true
    scoped_search :on => :composite, :complete_value => {true: true, false: false}

    def self.in_environment(env)
      joins(:content_view_environments).
        where("#{Katello::ContentViewEnvironment.table_name}.environment_id = ?", env.id)
    end

    def to_s
      name
    end

    def content_host_count
      systems.count
    end

    def copy(new_name)
      new_view = ContentView.new
      new_view.name = new_name
      new_view.attributes = self.attributes.slice("description", "organization_id", "default", "composite")
      new_view.save!
      new_view.repositories = self.repositories
      new_view.components = self.components

      self.content_view_puppet_modules.each do |puppet_module|
        new_view.content_view_puppet_modules << puppet_module.dup
      end

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
      new_view.save!
      new_view
    end

    def promoted?
      # if the view exists in more than 1 environment, it has been promoted
      self.environments.length > 1 ? true : false
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
      components.map(&:repositories).flatten
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
      Product.joins(:repositories).where("#{Katello::Repository.table_name}.id" => repos.map(&:id)).uniq
    end

    def version_products(env)
      repos = repos(env)
      Product.joins(:repositories).where("#{Katello::Repository.table_name}.id" => repos.map(&:id)).uniq
    end

    #list all products associated to this view across all versions
    def all_version_products
      Product.joins(:repositories).where("#{Katello::Repository.table_name}.id" => self.all_version_repos).uniq
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

      if foreman_env = Environment.find_by_katello_id(self.organization, from_env, self)
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

    def check_repo_conflicts
      duplicate_repositories.each do |repo|
        versions = components.with_library_repo(repo).uniq.map(&:name).join(", ")
        msg = _("Repository conflict: '%{repo}' is in %{versions}.") % {repo: repo.name, versions: versions}
        errors.add(:base, msg)
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

    def create_new_version(description = '', major = next_version, minor = 0, components = self.components)
      version = ContentViewVersion.create!(:major => major,
                                           :minor => minor,
                                           :content_view => self,
                                           :description => description,
                                           :components => components
                                          )

      increment!(:next_version) if minor == 0
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

      # Construct the pulp id using org/view/version or org/env/view
      pulp_id = ContentViewPuppetEnvironment.generate_pulp_id(organization.label, to_env.try(:label),
                                                              self.label, version.try(:version))

      ContentViewPuppetEnvironment.new(
        :environment => to_env,
        :content_view_version => to_version,
        :name => self.name,
        :pulp_id => pulp_id
      )
    end

    def create_puppet_env(options)
      build_puppet_env(options).save!
    end

    def computed_module_ids_by_repoid
      uuids = []
      names_and_authors = []
      puppet_modules = []

      if composite?
        uuids = component_modules_to_publish.collect { |puppet_module| puppet_module.uuid }
      else
        puppet_modules_to_publish.each do |cvpm|
          if cvpm.uuid
            uuids << cvpm.uuid
          else
            names_and_authors << { :name => cvpm.name, :author => cvpm.author }
          end
        end
      end

      puppet_modules = PuppetModule.where(:uuid => uuids) if uuids.present?

      if names_and_authors.present?
        names_and_authors.each do |name_and_author|
          puppet_module = ::Katello::PuppetModule.latest_module(
            name_and_author[:name],
            name_and_author[:author],
            self.organization.library.repositories.puppet_type
          )
          puppet_modules << puppet_module
        end
      end

      # In order to minimize the number of copy requests, organize the data by repoid.
      PuppetModule.group_by_repoid(puppet_modules)
    end

    def check_ready_to_publish!
      fail _("User must be logged in.") if ::User.current.nil?
      fail _("Cannot publish default content view") if default?
      check_composite_action_allowed!(organization.library)
      true
    end

    def check_composite_action_allowed!(env)
      if composite? && Setting['restrict_composite_view']
        # verify that the composite's component view versions exist in the target environment.
        components.each do |component|
          unless component.environments.include?(env)
            fail _("The action requested on this composite view cannot be performed until all of the "\
                   "component content view versions have been promoted to the target environment: %{env}.  "\
                   "This restriction is optional and can be modified in the Administrator -> Settings "\
                   "page using the restrict_composite_view flag.") %
                   { :env => env.name }
          end
        end
      end
      true
    end

    def check_remove_from_environment!(env)
      errors = []

      dependencies = {systems:                _("systems"),
                      activation_keys:        _("activation keys")
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

      dependencies = {environments:           _("environments"),
                      systems:                _("systems"),
                      activation_keys:        _("activation keys")
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
      # The id for a default view, will simply be the env id; otherwise, it
      # will be a combination of env id and view id.  The reason being,
      # for a default view, the same candlepin environment will be referenced
      # by the kt_environment and content_view_environment.
      self.default ? env.id.to_s : [env.id, self.id].join('-')
    end

    def confirm_not_promoted
      if promoted?
        errors.add(:base, _("cannot be deleted if it has been promoted."))
        return false
      end
      return true
    end

    def associate_puppet_content(puppet_env)
      unless content_view_puppet_modules.empty?
        modules_by_repoid = computed_module_ids_by_repoid
        async_tasks = []
        modules_by_repoid.each_pair do |repoid, puppet_module_ids|
          async_tasks << Katello.pulp_server.extensions.puppet_module.copy(repoid,
                                                                           puppet_env.pulp_id,
                                                                           :ids => puppet_module_ids)
        end
        PulpTaskStatus.wait_for_tasks(async_tasks)
      end
    end

    def associate_yum_content(cloned)
      # Intended Behaviour
      # Includes are cumulative -> If you say include errata and include packages, its the sum
      # Excludes are processed after includes
      # Excludes dont handle dependency. So if you say Include errata with pkgs P1, P2
      #         and exclude P1  and P1 has a dependency P1d1, what gets copied over is P1d1, P2

      # Another important aspect. PackageGroups & Errata are merely convinient ways to say "copy packages"
      # Its all about the packages

      # Algorithm:
      # 1) Compute all the packages to be whitelist/blacklist. In this process grok all the packages
      #    belonging to Errata/Package  groups etc  (work done by PackageClauseGenerator)
      # 2) Copy Packages (Whitelist - Blacklist) with their dependencies
      # 3) Unassociate the blacklisted items from the clone. This is so that if the deps were among
      #    the blacklisted packages, they would have gotten copied along in the previous step.
      # 4) Copy all errata and package groups
      # 5) Prune errata and package groups that have no existing packagea in the cloned repo
      # 6) Index for search.

      repo = cloned.library_instance_id ? cloned.library_instance : cloned
      applicable_filters = filters.applicable(repo).yum
      copy_clauses = nil
      remove_clauses = nil
      process_errata_and_groups = false

      if applicable_filters.any?
        clause_gen = Util::PackageClauseGenerator.new(repo, applicable_filters)
        clause_gen.generate
        copy_clauses = clause_gen.copy_clause
        remove_clauses = clause_gen.remove_clause
      end

      if applicable_filters.empty? || copy_clauses
        pulp_task = repo.clone_contents_by_filter(cloned, ContentViewFilter::PACKAGE, copy_clauses)
        PulpTaskStatus.wait_for_tasks([pulp_task])
        process_errata_and_groups = true
      end

      if remove_clauses
        pulp_task = cloned.unassociate_by_filter(ContentViewFilter::PACKAGE, remove_clauses)
        PulpTaskStatus.wait_for_tasks([pulp_task])
        process_errata_and_groups = true
      end

      if process_errata_and_groups
        group_tasks = [ContentViewFilter::ERRATA, ContentViewFilter::PACKAGE_GROUP].collect do |content_type|
          repo.clone_contents_by_filter(cloned, content_type, nil)
        end
        PulpTaskStatus.wait_for_tasks(group_tasks)
        cloned.purge_empty_groups_errata
      end

      PulpTaskStatus.wait_for_tasks([repo.clone_distribution(cloned)])
      PulpTaskStatus.wait_for_tasks([repo.clone_file_metadata(cloned)])
    end

    def related_resources
      self.organization
    end
  end
end
