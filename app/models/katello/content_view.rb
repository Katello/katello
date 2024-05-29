module Katello
  # rubocop:disable Metrics/ClassLength
  class ContentView < Katello::Model
    audited :associations => [:repositories, :environments, :filters]
    has_associated_audits
    include Ext::LabelFromName
    include Katello::Authorization::ContentView
    include ForemanTasks::Concerns::ActionSubject
    include Foreman::ObservableModel

    CONTENT_DIR = "content_views".freeze
    IMPORT_LIBRARY = "Import-Library".freeze
    EXPORT_LIBRARY = "Export-Library".freeze
    belongs_to :organization, :inverse_of => :content_views, :class_name => "::Organization"

    has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment", :dependent => :destroy
    has_many :environments, :class_name => "Katello::KTEnvironment", :through => :content_view_environments

    has_many :content_view_versions, :class_name => "Katello::ContentViewVersion", :dependent => :destroy
    alias_method :versions, :content_view_versions
    has_one :latest_version_object, -> { latest }, :class_name => "Katello::ContentViewVersion", :dependent => :destroy
    # Note the difference between content_view_components and component_composites both refer to
    # ContentViewComponent but mean different things.
    # content_view_components -> Topdown, given I am a composite CV get the associated components belonging to me
    #
    # component_composites -> Bottom Up, given I am a component CV get the associated composites that I belong to
    #
    has_many :content_view_components, :class_name => "Katello::ContentViewComponent", :dependent => :destroy,
             :inverse_of => :composite_content_view, :foreign_key => :composite_content_view_id, autosave: true

    has_many :component_composites, :class_name => "Katello::ContentViewComponent",
             :dependent => :destroy, :inverse_of => :content_view

    has_many :content_view_repositories, :class_name => 'Katello::ContentViewRepository',
             :dependent => :destroy, :inverse_of => :content_view
    has_many :repositories, :through => :content_view_repositories, :class_name => "Katello::Repository",
             :after_remove => :remove_repository

    has_many :filters, :dependent => :destroy, :class_name => "Katello::ContentViewFilter"

    has_many :content_view_environment_content_facets, :class_name => "Katello::ContentViewEnvironmentContentFacet",
             :through => :content_view_environments
    has_many :content_facets, :class_name => "Katello::Host::ContentFacet", :through => :content_view_environment_content_facets,
             :inverse_of => :content_views
    has_many :hosts, :class_name => "::Host::Managed", :through => :content_facets,
             :inverse_of => :content_views

    has_many :content_view_environment_activation_keys, :class_name => "Katello::ContentViewEnvironmentActivationKey",
             :through => :content_view_environments
    has_many :activation_keys, :class_name => "Katello::ActivationKey", :through => :content_view_environment_activation_keys,
             :inverse_of => :content_views

    has_many :hostgroup_content_facets, :class_name => "Katello::Hostgroup::ContentFacet",
             :inverse_of => :content_view, :dependent => :nullify
    has_many :hostgroups, :class_name => "::Hostgroup", :through => :hostgroup_content_facets,
             :inverse_of => :content_view

    has_many :repository_references, :class_name => 'Katello::Pulp3::RepositoryReference',
             :dependent => :destroy, :inverse_of => :content_view

    validates_lengths_from_database :except => [:label]
    validates :label, :uniqueness => { :scope => :organization_id },
              :presence => true
    validates :name, :presence => true, :uniqueness => { :scope => :organization_id }
    validates :organization_id, :presence => true
    validate :check_non_composite_components
    validate :check_docker_conflicts
    validate :check_non_composite_auto_publish
    validate :check_default_label_name, if: :default?
    validates :composite, :inclusion => [true, false]
    validates :composite,
              inclusion: { in: [false], message: "Composite Content Views can not solve dependencies" },
              if: :solve_dependencies
    validates :import_only, :inclusion => [true, false]
    validates :import_only,
              inclusion: { in: [false], message: "Import-only Content Views can not be Composite" },
              if: :composite
    validates :import_only,
              inclusion: { in: [false], message: "Import-only Content Views can not solve dependencies" },
              if: :solve_dependencies
    validate :import_only_immutable
    validates :generated_for,
              exclusion: { in: [:none], message: "Generated Content Views can not be Composite" },
              if: :composite
    validates :generated_for,
              exclusion: { in: [:none], message: "Generated Content Views can not solve dependencies" },
              if: :solve_dependencies

    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label

    scope :default, -> { where(:default => true) }
    scope :non_default, -> { where(:default => false) }
    scope :composite, -> { where(:composite => true) }
    scope :non_composite, -> { where(:composite => [nil, false]) }
    scope :generated, -> { where.not(:generated_for => :none) }
    scope :generated_for_repository, -> {
      where(:generated_for => [:repository_export,
                               :repository_import,
                               :repository_export_syncable])
    }
    scope :ignore_generated, ->(include_library_generated: false) {
      ignored_values = [:repository_export,
                        :repository_import,
                        :library_export_syncable,
                        :repository_export_syncable]
      ignored_values += [:library_export, :library_import] if include_library_generated
      where.not(generated_for: ignored_values)
    }
    scope :generated_for_library, -> { where(:generated_for => [:library_export, :library_import, :library_export_syncable]) }

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :label, :complete_value => true
    scoped_search :on => :composite, :complete_value => true
    scoped_search :on => :generated_for, :complete_value => true
    scoped_search :on => :default # just for ordering
    scoped_search :on => :name, :complete_value => true,
                  :rename => :content_views,
                  :operators => ['='],
                  :ext_method => :find_components_by_cv_name

    def self.find_components_by_cv_name(_key, operator, value)
      kcv = Katello::ContentView.table_name
      kcvc = Katello::ContentViewComponent.table_name
      { :conditions => "#{kcv}.composite = 't' AND #{kcv}.id IN (SELECT #{kcvc}.composite_content_view_id FROM #{kcvc} WHERE #{kcvc}.content_view_id IN (SELECT #{kcv}.id FROM #{kcv} WHERE #{kcv}.name #{operator} ?))",
        :parameter => [value],
      }
    end

    def self.completer_scope_options(search)
      if search.include?('content_views')
        # Don't autocomplete CCV names when searching for components
        { :value_filter => { :composite => false } }
      else
        {}
      end
    end

    enum generated_for: {
      none: 0,
      library_export: 1,
      repository_export: 2,
      library_import: 3,
      repository_import: 4,
      library_export_syncable: 5,
      repository_export_syncable: 6,
    }, _prefix: true

    set_crud_hooks :content_view

    apipie :class, desc: "A class representing #{model_name.human} object" do
      name 'Content View'
      refs 'ContentView'
      sections only: %w[all additional]
      prop_group :katello_idname_props, Katello::Model, meta: { friendly_name: 'Content View' }
      property :label, String, desc: 'Returns label of the Content View'
      property :organization, 'Organization', desc: 'Returns organization object'
    end

    def self.in_environment(env)
      joins(:content_view_environments).
        where("#{Katello::ContentViewEnvironment.table_name}.environment_id = ?", env.id)
    end

    def self.published_with_repositories(root_repository)
      joins(:content_view_versions => :repositories).where("katello_repositories.root_id" => root_repository.id).uniq
    end

    def self.in_organization(org)
      where(organization_id: org.id) unless org.nil?
    end

    def to_s
      name
    end

    def library_import?
      name == IMPORT_LIBRARY
    end

    def library_export?
      name.start_with? EXPORT_LIBRARY
    end

    def generated_for_repository?
      generated_for_repository_export? || generated_for_repository_import? || generated_for_repository_export_syncable?
    end

    def generated_for_library?
      generated_for_library_export? || generated_for_library_import? || generated_for_library_export_syncable?
    end

    def content_host_count
      hosts.size
    end

    def component_ids
      components.map(&:id)
    end

    def components
      content_view_components.map(&:latest_version).compact.freeze
    end

    def sorted_versions
      versions.order('created_at DESC')
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
        when ContentViewDebFilter.name
          filter.deb_rules.each do |rule|
            new_filter.deb_rules << rule.dup
          end
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

      copy_filters(new_view)
      new_view.save!
      new_view
    end

    def promoted?
      # if the view exists in more than 1 environment, it has been promoted
      self.environments.many?
    end

    def generated?
      !generated_for_none?
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
          :environments => v.environments.map { |e| e.name },
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

    def in_environment?(env)
      environments.include?(env)
    end

    apipie :method, 'Returns the Katello::ContentViewVersion for a given Lifecycle Environment' do
      required :env, 'Katello::KTEnvironment', desc: 'a __Katello::KTEnvironment__ object for which we load the __Katello::ContentViewVersion__ object'
      returns 'Katello::ContentViewVersion'
    end

    def version(env)
      self.versions.in_environment(env).order("#{Katello::ContentViewVersion.table_name}.id ASC").readonly(false).last
    end

    def latest_version
      latest_version_object.try(:version)
    end

    def latest_version_id
      latest_version_object.try(:id)
    end

    def latest_version_env
      latest_version_object.try(:environments) || []
    end

    def last_task
      last_task_id = history.order(:created_at)&.last&.task_id
      last_task_id ? ForemanTasks::Task.find_by(id: last_task_id) : nil
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

    def repos(env = nil)
      if env
        repo_ids = versions.flat_map { |version| version.repositories.in_environment(env) }.map(&:id)
      else
        repo_ids = versions.flat_map { |version| version.repositories }.map(&:id)
      end
      Repository.where(:id => repo_ids)
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

    def repositories_to_publish(override_components = nil)
      if composite?
        components_to_publish = []
        components.each do |component|
          override_component = override_components&.detect do |override_cvv|
            override_cvv.content_view == component.content_view
          end

          if override_component
            components_to_publish << override_component
          else
            components_to_publish << component
          end
        end
        ids = components_to_publish.flat_map { |version| version.repositories.archived }.map(&:id)
        Repository.where(:id => ids)
      else
        repositories
      end
    end

    def repositories_to_publish_ids
      composite? ? repositories_to_publish.pluck(&:id) : repository_ids
    end

    def repositories_to_publish_by_library_instance(override_components = nil)
      # retrieve the list of repositories in a hash, where the key
      # is the library instance id, and the value is an array
      # of the repositories for that instance.
      repositories_to_publish(override_components).inject({}) do |result, repo|
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
      component_composites.where(latest: true).joins(:composite_content_view).where(self.class.table_name => { auto_publish: true })
    end

    def publish_repositories(override_components = nil)
      repositories = composite? ? repositories_to_publish_by_library_instance(override_components).values : repositories_to_publish
      repositories.each do |repos|
        if repos.is_a? Array
          yield repos
        else
          yield [repos]
        end
      end
    end

    def update_host_statuses(environment)
      # update errata applicability counts for all hosts in the CV & LE
      Location.no_taxonomy_scope do
        User.as_anonymous_admin do
          ::Katello::Host::ContentFacet.with_content_views(self).with_environments(environment).each do |facet|
            facet.update_applicability_counts
            facet.update_errata_status
          rescue NoMethodError
            Rails.logger.warn _('Errata statuses not updated for deleted content facet with UUID %s') % facet.uuid
          end
        end
      end
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

    def check_default_label_name
      if default? && !(name == 'Default Organization View' && label == 'Default_Organization_View')
        errors.add(:base, _("Name and label of default content view should not be changed"))
      end
    end

    def check_docker_conflicts
      duplicate_docker_repos.each do |repo|
        msg = _("Container Image repo '%{repo}' is present in multiple component content views.") % { repo: repo.name }
        errors.add(:base, msg)
      end
    end

    def content_view_environment(environment)
      self.content_view_environments.where(:environment_id => environment.try(:id)).first
    end

    def update_cp_content(env)
      view_env = content_view_environment(env)

      view_env&.update_cp_content
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

      # TODO: If a controller creates a new version and then uses latest_version_object, the old data is displayed.
      #       To prevent this, a 'reload' would currently be necessary, but this is not very performant.
      #       However, this is currently not a problem because after your create_new_version there is no immediate
      #       access to latest_version_object, but the ContentView object is first completely reloaded.
      #
      #       In Rails 7.1, individual connections can be reloaded:
      #       https://www.shakacode.com/blog/rails-7-1-allows-resetting-singular-associations/

      update(:next_version => major.to_i + 1) unless major.to_i < next_version
      version
    end

    def check_ready_to_import!
      fail _("Cannot import a composite content view") if composite?
      fail _("This Content View must be set to Import-only before performing an import") unless import_only?
      true
    end

    def check_ready_to_publish!(importing: false, syncable: false)
      fail _("User must be logged in.") if ::User.current.nil?
      fail _("Cannot publish default content view") if default?

      if importing
        check_ready_to_import!
      else
        fail _("Import-only content views can not be published directly") if import_only? && !syncable
        check_repositories_blocking_publish!
        check_composite_action_allowed!(organization.library)
        check_docker_repository_names!([organization.library])
        check_orphaned_content_facets!(environments: self.environments)
      end

      true
    end

    def check_repositories_blocking_publish!
      blocking_tasks = repositories&.map { |repo| repo.blocking_task }&.compact

      if blocking_tasks&.any?
        errored_tasks = blocking_tasks.uniq.map { |task| "- #{Setting['foreman_url']}/foreman_tasks/tasks/#{task&.id}" }.join("\n")
        fail _("Pending tasks detected in repositories of this content view. Please wait for the tasks: " +
                 errored_tasks + " before publishing.")
      end
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

    def check_orphaned_content_facets!(environments: [])
      Location.no_taxonomy_scope do
        User.as_anonymous_admin do
          ::Katello::Host::ContentFacet.with_content_views(self).with_environments(environments).each do |facet|
            unless facet.host
              fail _("Orphaned content facets for deleted hosts exist for the content view and environment. Please run rake task : katello:clean_orphaned_facets and try again!")
            end
          end
        end
      end
    end

    def check_remove_from_environment!(env)
      check_orphaned_content_facets!(environments: [env])
      errors = []

      dependencies = { hosts: _("hosts"),
                       activation_keys: _("activation keys"),
      }

      dependencies.each do |key, name|
        if (models = self.association(key).scope.in_environments(env)).any?
          errors << _("Cannot remove '%{view}' from environment '%{env}' due to associated %{dependent}: %{names}.") %
            { view: self.name, env: env.name, dependent: name, names: models.map(&:name).join(", ") }
        end
      end

      fail errors.join(" ") if errors.any?
      return true
    end

    def check_ready_to_destroy!
      check_orphaned_content_facets!(environments: self.environments)
      errors = []

      dependencies = { environments: _("environments"),
                       hosts: _("hosts"),
                       activation_keys: _("activation keys"),
      }

      dependencies.each do |key, name|
        if (models = self.association(key).scope).any?
          errors << _("Cannot delete '%{view}' due to associated %{dependent}: %{names}.") %
            { view: self.name, dependent: name, names: models.map(&:name).join(", ") }
        end
      end

      fail errors.join(" ") if errors.any?
      return true
    end

    def self.humanize_class_name(_name = nil)
      _("Content Views")
    end

    def version_count
      content_view_versions.size
    end

    def on_demand_repositories
      repositories.on_demand
    end

    def related_cv_count
      if composite
        content_view_components.length
      else
        component_composites.length
      end
    end

    def related_composite_cvs
      content_views = []
      component_composites.each do |cv|
        cv_id = cv.composite_content_view_id
        cv_name = ContentView.find(cv_id).name
        content_views.push(
          {
            id: cv_id,
            name: cv_name,
          }
        )
      end
      content_views
    end

    def composite_cv_components_changed?
      return true unless latest_version_object
      published_component_version_ids = latest_version_object.components.pluck(:id) || []
      unpublished_component_version_ids = content_view_components.where(latest: false).pluck(:content_view_version_id) || []
      content_view_components.where(latest: true).each do |latest_component|
        unpublished_component_version_ids << latest_component.content_view&.latest_version_object&.id
      end
      published_component_version_ids.compact.uniq.sort != unpublished_component_version_ids.compact.uniq.sort
    end

    def last_publish_task_success?
      last_publish_result = latest_version_object&.history&.publish&.first&.task&.result
      return last_publish_result.present? && last_publish_result == 'success'
    end

    def cv_repo_indexed_after_last_published?
      repositories.any? { |repo| repo.last_indexed && repo.last_indexed > latest_version_object.created_at }
    end

    def unpublishable?
      default? || import_only? || generated?
    end

    def needs_publish?
      #Returns
      # True:
      #     a) When content/repo/filter change audit records exist
      #     b) CV hasn't ever been published
      #     c) CV dependency_solving != latest_version.applied_filters.dependency_solving
      #     d) If repo was indexed after cv publish. This can happen under 3 cases:
      #       i) Index runs because last index(before publish) had failed and repo is picked up for index even if pulp publication hasn't changed.
      #       ii) Complete sync runs or sync adds/removes new content (Already true because new pulp publication/version gets created)
      #       iii) repo.index_content is run. (This doesn't necessarily indicate contents changed. Corner case where we play safe and return true)
      # nil:
      #     a) When CV version creation audit is missing(Indicating audit cleanup)
      #     b) Version doesn't have audited_filters set indicating
      #     it was published before 4.9 upgrade when we started auditing changes on the CV.
      #     c) Last publish task failed leaving us with no way of knowing if all content in the version is correct.
      # False:
      #     a) No changes were detected via audits *and*
      #        Audit for CV publish exists (Audits haven't been cleaned up)
      #        *and* applied_filters field is set(Published after upgrade)
      #     b) Default, import only and generated CVs can not be published, hence these will always return false.
      #
      return false if unpublishable?
      return true unless latest_version_object
      return nil unless last_publish_task_success?
      return composite_cv_components_changed? if composite?
      # return true if the audit records clearly show we have unpublished changes
      return true if audited_changes_present?
      # return true if the dependency solving changed for CV between last publish and now
      return true if dependency_solving_changed?
      # return true if any child repo's indexed_at > last_version.created_at
      return true if cv_repo_indexed_after_last_published?
      # if we didn't return `true` already, either the audit records show that we don't need to publish, or we may
      # have insufficient data to make the determination (either audits were cleaned, or never got created at all).
      # first, check for the `create` audit record; its absence indicates that audits were cleaned some time after
      # the cv version was created (i.e. the first indeterminate state) so we return `nil` in that case.
      return nil unless latest_version_object&.audits&.where(action: "create")&.exists?
      # even when the `create` audit exists, the other audits could still be absent due to the latest cv version
      # being created prior to the tracking of the other audits that were added in katello 4.9 (i.e. the second indeterminate state).
      # We determine that using the `applied_filters` field. This field was added in Katello 4.9 and is set to nil for
      # all versions published before that upgrade.
      # If `applied_filters` is nil we can not deterministically rule out changes before the upgrade
      # not captured by newer content change and filter change audits.
      # If that field is not nil, the version was published after upgrade, hence we have all the information to rule out
      # any audited changes to the CV and we can deterministically return false
      latest_version_object.applied_filters.nil? ? nil : false
    end

    def audited_changes_present?
      latest_version_created_at = latest_version_object.created_at
      cv_repository_ids = repositories.pluck(:id)

      audited_changes_like = ->(param) {
        Arel.sql("#{Audit.table_name}.audited_changes ilike '%#{param}%'")
      }

      table = Audit.arel_table
      repository_condition = table[:auditable_id].eq(id)
                                                 .and(table[:auditable_type].eq('Katello::ContentView'))
                                                 .and(audited_changes_like.call("repository_ids"))

      cv_repository_condition = table[:auditable_id].in(cv_repository_ids)
                                                    .and(table[:auditable_type].eq('Katello::Repository'))
                                                    .and(Arel.sql("(#{audited_changes_like.call("publication_href")} OR #{audited_changes_like.call("version_href")})"))

      content_view_filter_condition = table[:auditable_type].eq('Katello::ContentViewFilter').and(table[:associated_id].eq(id))

      filter_rule_condition = table[:associated_id].eq(id).and(table[:auditable_type].matches('%FilterRule%'))

      base_query = table[:created_at].gt(latest_version_created_at)

      final_query = base_query.and(repository_condition.or(cv_repository_condition).or(content_view_filter_condition).or(filter_rule_condition))

      Audit.where(final_query).exists?
    end

    def dependency_solving_changed?
      latest_version_object.applied_filters && solve_dependencies != latest_version_object.applied_filters['dependency_solving']
    end

    def filtered?
      filters.present?
    end

    def blocking_task
      blocking_task_labels = [
        ::Actions::Katello::ContentView::Publish.name,
      ]
      ForemanTasks::Task::DynflowTask.where(:label => blocking_task_labels)
                                     .where.not(state: 'stopped')
                                     .for_resource(self)
                                     .order(:started_at)
                                     .last
    end

    protected

    def remove_repository(repository)
      filters.each do |filter_item|
        repo_exists = Repository.unscoped.joins(:filters).where(
          ContentViewFilter.table_name => { :id => filter_item.id }, :id => repository.id).count
        if repo_exists
          filter_item.repositories.delete(repository)
          filter_item.save!
        end
      end
    end

    private

    def import_only_immutable
      if import_only_changed? && self.persisted?
        errors.add(:import_only, _("Import-only can not be changed after creation"))
      end
    end

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
      allow :id, :name, :label, :version, :organization
    end
  end
end
