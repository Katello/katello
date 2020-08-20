module Katello
  # rubocop:disable Metrics/ClassLength
  class Repository < Katello::Model
    audited

    #pulp uses pulp id to sync with 'yum_distributor' on the end
    PULP_ID_MAX_LENGTH = 220

    validates_lengths_from_database
    before_destroy :assert_deletable
    before_create :downcase_pulp_id

    include ForemanTasks::Concerns::ActionSubject
    include Glue::Candlepin::Repository
    include Glue::Pulp::Repo if SETTINGS[:katello][:use_pulp]

    include Glue if (SETTINGS[:katello][:use_cp] || SETTINGS[:katello][:use_pulp])
    include Authorization::Repository
    include Katello::Engine.routes.url_helpers

    include ERB::Util
    include ::ScopedSearchExtensions

    AUDIT_SYNC_ACTION = 'sync'.freeze

    DEB_TYPE = 'deb'.freeze
    YUM_TYPE = 'yum'.freeze
    FILE_TYPE = 'file'.freeze
    PUPPET_TYPE = 'puppet'.freeze
    DOCKER_TYPE = 'docker'.freeze
    OSTREE_TYPE = 'ostree'.freeze
    ANSIBLE_COLLECTION_TYPE = 'ansible_collection'.freeze

    define_model_callbacks :sync, :only => :after

    belongs_to :root, :inverse_of => :repositories, :class_name => "Katello::RootRepository"
    belongs_to :environment, :inverse_of => :repositories, :class_name => "Katello::KTEnvironment"
    belongs_to :library_instance, :class_name => "Katello::Repository", :inverse_of => :library_instances_inverse, :foreign_key => :library_instance_id
    has_many :library_instances_inverse,
             :class_name  => 'Katello::Repository',
             :dependent   => :restrict_with_exception,
             :foreign_key => :library_instance_id

    has_one :product, :through => :root

    has_many :content_view_repositories, :class_name => "Katello::ContentViewRepository",
                                         :dependent => :destroy, :inverse_of => :repository
    has_many :content_views, :through => :content_view_repositories

    has_many :repository_errata, :class_name => "Katello::RepositoryErratum", :dependent => :delete_all
    has_many :errata, :through => :repository_errata

    has_many :repository_rpms, :class_name => "Katello::RepositoryRpm", :dependent => :delete_all
    has_many :rpms, :through => :repository_rpms

    has_many :repository_srpms, :class_name => "Katello::RepositorySrpm", :dependent => :delete_all
    has_many :srpms, :through => :repository_srpms

    has_many :repository_file_units, :class_name => "Katello::RepositoryFileUnit", :dependent => :delete_all
    has_many :files, :through => :repository_file_units, :source => :file_unit
    alias_attribute :file_units, :files

    has_many :repository_puppet_modules, :class_name => "Katello::RepositoryPuppetModule", :dependent => :delete_all
    has_many :puppet_modules, :through => :repository_puppet_modules

    has_many :repository_docker_manifests, :class_name => "Katello::RepositoryDockerManifest", :dependent => :delete_all
    has_many :docker_manifests, :through => :repository_docker_manifests

    has_many :repository_docker_manifest_lists, :class_name => "Katello::RepositoryDockerManifestList", :dependent => :delete_all
    has_many :docker_manifest_lists, :through => :repository_docker_manifest_lists

    has_many :yum_metadata_files, :dependent => :destroy, :class_name => "Katello::YumMetadataFile"

    has_many :repository_docker_tags, :class_name => "Katello::RepositoryDockerTag", :dependent => :delete_all
    has_many :docker_tags, :through => :repository_docker_tags

    has_many :repository_docker_meta_tags, :class_name => "Katello::RepositoryDockerMetaTag", :dependent => :delete_all
    has_many :docker_meta_tags, :through => :repository_docker_meta_tags

    has_many :repository_ostree_branches, :class_name => "Katello::RepositoryOstreeBranch", :dependent => :delete_all
    has_many :ostree_branches, :through => :repository_ostree_branches

    has_many :repository_debs, :class_name => "Katello::RepositoryDeb", :dependent => :delete_all
    has_many :debs, :through => :repository_debs

    has_many :content_facet_repositories, :class_name => "Katello::ContentFacetRepository", :dependent => :delete_all
    has_many :content_facets, :through => :content_facet_repositories

    has_many :repository_package_groups, :class_name => "Katello::RepositoryPackageGroup", :dependent => :delete_all
    has_many :package_groups, :through => :repository_package_groups

    has_many :kickstart_content_facets, :class_name => "Katello::Host::ContentFacet", :foreign_key => :kickstart_repository_id,
                          :inverse_of => :kickstart_repository, :dependent => :nullify

    has_many :kickstart_hostgroup_content_facets, :class_name => "Katello::Hostgroup::ContentFacet", :foreign_key => :kickstart_repository_id,
             :inverse_of => :kickstart_repository, :dependent => :nullify

    has_many :kickstart_hostgroups, :class_name => "::Hostgroup", :through => :kickstart_hostgroup_content_facets

    has_many :repository_module_streams, class_name: "Katello::RepositoryModuleStream", dependent: :delete_all
    has_many :module_streams, through: :repository_module_streams

    has_many :repository_ansible_collections, :class_name => "Katello::RepositoryAnsibleCollection", :dependent => :delete_all
    has_many :ansible_collections, :through => :repository_ansible_collections
    has_many :repository_content_view_filters, :class_name => "Katello::RepositoryContentViewFilter", :dependent => :delete_all
    has_many :filters, :through => :repository_content_view_filters

    belongs_to :content_view_version, :inverse_of => :repositories, :class_name => "Katello::ContentViewVersion"
    has_many :distribution_references, :class_name => 'Katello::Pulp3::DistributionReference', :foreign_key => :repository_id,
             :dependent => :destroy, :inverse_of => :repository

    validates_with Validators::ContainerImageNameValidator, :attributes => :container_repository_name, :allow_blank => false, :if => :docker?
    validates :container_repository_name, :if => :docker?, :uniqueness => {message: ->(object, _data) do
      _("for repository '%{name}' is not unique and cannot be created in '%{env}'. Its Container Repository Name (%{container_name}) conflicts with an existing repository.  Consider changing the Lifecycle Environment's Registry Name Pattern to something more specific.") %
          {name: object.name, container_name: object.container_repository_name, :env => object.environment.name}
    end}

    before_validation :set_pulp_id
    before_validation :set_container_repository_name, :if => :docker?

    scope :has_url, -> { joins(:root).where.not("#{RootRepository.table_name}.url" => nil) }
    scope :on_demand, -> { joins(:root).where("#{RootRepository.table_name}.download_policy" => ::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND) }
    scope :in_default_view, -> { joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => true) }
    scope :in_non_default_view, -> { joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => false) }
    scope :deb_type, -> { with_type(DEB_TYPE) }
    scope :yum_type, -> { with_type(YUM_TYPE) }
    scope :file_type, -> { with_type(FILE_TYPE) }
    scope :puppet_type, -> { with_type(PUPPET_TYPE) }
    scope :docker_type, -> { with_type(DOCKER_TYPE) }
    scope :ostree_type, -> { with_type(OSTREE_TYPE) }
    scope :ansible_collection_type, -> { with_type(ANSIBLE_COLLECTION_TYPE) }
    scope :non_puppet, -> { with_type(RepositoryTypeManager.repository_types.keys - [PUPPET_TYPE]) }
    scope :non_archived, -> { where('environment_id is not NULL') }
    scope :archived, -> { where('environment_id is NULL') }
    scope :in_published_environments, -> { in_content_views(Katello::ContentView.non_default).where.not(:environment_id => nil) }
    scope :order_by_root, ->(attr) { joins(:root).order("#{Katello::RootRepository.table_name}.#{attr}") }
    scope :with_content, ->(content) { joins(Katello::RepositoryTypeManager.find_content_type(content).model_class.repository_association_class.name.demodulize.underscore.pluralize.to_sym).distinct }

    scoped_search :on => :name, :relation => :root, :complete_value => true
    scoped_search :rename => :product, :on => :name, :relation => :product, :complete_value => true
    scoped_search :rename => :product_id, :on => :id, :relation => :product
    scoped_search :on => :content_type, :relation => :root, :complete_value => -> do
      Katello::RepositoryTypeManager.repository_types.keys.each_with_object({}) { |value, hash| hash[value.to_sym] = value }
    end
    scoped_search :on => :content_view_id, :relation => :content_view_repositories, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :distribution_version, :complete_value => true
    scoped_search :on => :distribution_arch, :complete_value => true
    scoped_search :on => :distribution_family, :complete_value => true
    scoped_search :on => :distribution_variant, :complete_value => true
    scoped_search :on => :distribution_bootable, :complete_value => true
    scoped_search :on => :distribution_uuid, :complete_value => true
    scoped_search :on => :redhat, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_redhat
    scoped_search :on => :container_repository_name, :complete_value => true
    scoped_search :on => :description, :relation => :root, :only_explicit => true
    scoped_search :on => :name, :relation => :product, :rename => :product_name
    scoped_search :on => :id, :relation => :product, :rename => :product_id, :only_explicit => true
    scoped_search :on => :label, :relation => :root, :complete_value => true, :only_explicit => true
    scoped_search :on => :content_label, :ext_method => :search_by_content_label

    delegate :product, :redhat?, :custom?, :to => :root
    delegate :yum?, :docker?, :puppet?, :deb?, :file?, :ostree?, :ansible_collection?, :to => :root
    delegate :name, :label, :docker_upstream_name, :url, :to => :root

    delegate :name, :created_at, :updated_at, :major, :minor, :gpg_key_id, :gpg_key, :arch, :label, :url, :unprotected,
             :content_type, :product_id, :checksum_type, :docker_upstream_name, :mirror_on_sync, :"mirror_on_sync?",
             :download_policy, :verify_ssl_on_sync, :"verify_ssl_on_sync?", :upstream_username, :upstream_password,
             :ostree_upstream_sync_policy, :ostree_upstream_sync_depth, :deb_releases, :deb_components, :deb_architectures,
             :ssl_ca_cert_id, :ssl_ca_cert, :ssl_client_cert, :ssl_client_cert_id, :ssl_client_key_id,
             :ssl_client_key, :ignorable_content, :description, :docker_tags_whitelist, :ansible_collection_requirements, :http_proxy_policy, :http_proxy_id, :to => :root

    delegate :content_id, to: :root, allow_nil: true

    def self.with_type(content_type)
      joins(:root).where("#{RootRepository.table_name}.content_type" => content_type)
    end

    def to_label
      name
    end

    def backend_service(smart_proxy, force_pulp3 = false)
      if force_pulp3 || smart_proxy.pulp3_support?(self)
        @service ||= Katello::Pulp3::Repository.instance_for_type(self, smart_proxy)
      else
        @service ||= Katello::Pulp::Repository.instance_for_type(self, smart_proxy)
      end
    end

    def backend_content_service(smart_proxy)
      backend_service(smart_proxy).content_service
    end

    def backend_content_unit_service(smart_proxy, content_unit_type)
      backend_service(smart_proxy).content_service(content_unit_type)
    end

    def organization
      if self.environment
        self.environment.organization
      else
        self.content_view.organization
      end
    end

    def organization_id
      organization&.id
    end

    def audit_sync
      write_audit(action: AUDIT_SYNC_ACTION, comment: _('Successfully synchronized.'), audited_changes: {})
    end

    def set_pulp_id
      return if self.pulp_id

      if self.content_view.default?
        items = [SecureRandom.uuid]
      elsif self.environment
        items = [organization.id, content_view.label, environment.label, library_instance.pulp_id]
      else
        version = self.content_view_version.version.gsub('.', '_')
        items = [organization.id, content_view.label, "v#{version}", library_instance.pulp_id]
      end
      self.pulp_id = items.join('-')
      self.pulp_id = SecureRandom.uuid if self.pulp_id.length > PULP_ID_MAX_LENGTH
    end

    def set_container_repository_name
      self.container_repository_name = Repository.safe_render_container_name(self)
    end

    def content_view
      self.content_view_version.content_view
    end

    def library_instance?
      self.content_view.default?
    end

    def self.undisplayable_types
      ret = [::Katello::Repository::CANDLEPIN_DOCKER_TYPE]

      unless ::Katello::RepositoryTypeManager.enabled?(Repository::OSTREE_TYPE)
        ret << ::Katello::Repository::CANDLEPIN_OSTREE_TYPE
      end

      ret
    end

    def self.in_organization(org)
      where("#{Repository.table_name}.environment_id" => org.kt_environments.pluck("#{KTEnvironment.table_name}.id"))
    end

    def self.in_environment(env_id)
      where(environment_id: env_id)
    end

    def self.in_product(prod)
      where(:root_id => RootRepository.where(product_id: prod))
    end

    def self.in_content_views(views)
      joins(:content_view_version)
        .where("#{Katello::ContentViewVersion.table_name}.content_view_id" => views.map(&:id))
    end

    def self.feed_ca_cert(url)
      file = feed_ca_file(url)
      File.read(file) if file
    end

    def self.feed_ca_file(url)
      ::Katello::Resources::CDN::CdnResource.ca_file if ::Katello::Resources::CDN::CdnResource.redhat_cdn?(url)
    end

    def archive?
      self.environment.nil?
    end

    def in_default_view?
      content_view_version&.default_content_view?
    end

    def on_demand?
      root.download_policy == Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND
    end

    def yum_gpg_key_url
      # if the repo has a gpg key return a url to access it
      if self.root.gpg_key.try(:content).present?
        "../..#{gpg_key_content_api_repository_url(self, :only_path => true)}"
      end
    end

    def product_type
      redhat? ? "redhat" : "custom"
    end

    def self.errata_with_package_counts(repo)
      repository_rpm = Katello::RepositoryRpm.table_name
      repository_errata = Katello::RepositoryErratum.table_name
      rpm = Katello::Rpm.table_name
      errata = Katello::Erratum.table_name
      erratum_package = Katello::ErratumPackage.table_name
      ::Katello::Erratum.joins(
        "INNER JOIN #{erratum_package} on #{erratum_package}.erratum_id = #{errata}.id",
        "INNER JOIN #{repository_errata} on #{repository_errata}.erratum_id = #{errata}.id",
        "INNER JOIN #{rpm} on #{rpm}.filename = #{erratum_package}.filename",
        "INNER JOIN #{repository_rpm} on #{repository_rpm}.rpm_id = #{rpm}.id").
        where("#{repository_rpm}.repository_id" => repo.id).
        where("#{repository_errata}.repository_id" => repo.id).
        group("#{errata}.id").count
    end

    def self.errata_with_module_stream_counts(repo)
      repository_errata = Katello::RepositoryErratum.table_name
      errata = Katello::Erratum.table_name
      erratum_package = Katello::ErratumPackage.table_name
      repository_module_stream = Katello::RepositoryModuleStream.table_name
      msep = ::Katello::ModuleStreamErratumPackage.table_name
      ::Katello::Erratum.joins(
        "INNER JOIN #{erratum_package} on #{erratum_package}.erratum_id = #{errata}.id",
        "INNER JOIN #{msep} on #{msep}.erratum_package_id = #{erratum_package}.id",
        "INNER JOIN #{repository_errata} on #{repository_errata}.erratum_id = #{errata}.id",
        "INNER JOIN #{repository_module_stream} on #{repository_module_stream}.module_stream_id = #{msep}.module_stream_id").
        where("#{repository_module_stream}.repository_id" => repo.id).
        where("#{repository_errata}.repository_id" => repo.id).
        group("#{errata}.id").count
    end

    def fetch_package_errata_to_keep
      errata_counts = ::Katello::Repository.errata_with_package_counts(self)
      if errata_counts.any?
        errata_counts_in_library = ::Katello::Repository.errata_with_package_counts(library_instance)
        errata_counts.keep_if { |id| errata_counts[id] == errata_counts_in_library[id] }
        errata_counts.keys
      else
        []
      end
    end

    def fetch_module_errata_to_filter
      errata_counts = ::Katello::Repository.errata_with_module_stream_counts(self)
      errata_counts_in_library = ::Katello::Repository.errata_with_module_stream_counts(library_instance)
      if errata_counts_in_library.any?
        errata_counts_in_library.keep_if { |id| errata_counts[id] != errata_counts_in_library[id] }
        errata_counts_in_library.keys
      else
        []
      end
    end

    def partial_errata
      return [] if library_instance?

      partial_errata = self.errata
      errata_to_keep = fetch_package_errata_to_keep - fetch_module_errata_to_filter

      if errata_to_keep.any?
        partial_errata = self.errata.where("#{Katello::Erratum.table_name}.id NOT IN (?)", errata_to_keep)
      end

      partial_errata
    end

    def remove_partial_errata!
      found = partial_errata.to_a
      yield(found) if block_given?
      self.repository_errata.where(:erratum_id => found.map(&:id)).delete_all
      found
    end

    def siblings
      content_view_version.archived_repos.where.not(:id => id)
    end

    def clones
      self.root.repositories.where.not(:id => library_instance_id || id)
    end

    def all_instances
      self.root.repositories
    end

    def group
      all_instances
    end

    def to_hash(content_source = nil)
      {id: id, name: label, url: full_path(content_source)}
    end

    #is the repo cloned in the specified environment
    def cloned_in?(env)
      !get_clone(env).nil?
    end

    def promoted?
      if environment&.library?
        self.clones.any?
      else
        false
      end
    end

    def get_clone(env)
      if self.content_view.default
        # this repo is part of a default content view
        Repository.in_environment(env).clones.
            joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => true).first
      else
        # this repo is part of a content view that was published from a user created view
        self.content_view.get_repo_clone(env, self).first
      end
    end

    # Returns true if the pulp_task_id was triggered by the last synchronization
    # action for the repository. Dynflow action handles the synchronization
    # by it's own so no need to synchronize it again in this callback. Since the
    # callbacks are run just after synchronization is finished, it should be enough
    # to check for the last synchronization task.
    def dynflow_handled_last_sync?(pulp_task_id)
      task = ForemanTasks::Task::DynflowTask.for_action(::Actions::Katello::Repository::Sync).
          for_resource(self).order(:started_at).last
      return task && task.main_action.pulp_task_id == pulp_task_id
    end

    def generate_content_path
      path = content.content_url
      root.substitutions.each do |key, value|
        path = path.gsub("$#{key}", value) if value
      end
      path
    end

    def library_instance_or_self
      self.library_instance || self
    end

    def generate_repo_path(content_path = nil)
      _org, _content, content_path = library_instance_or_self.relative_path.split("/", 3) if content_path.blank?
      content_path = content_path.sub(%r|^/|, '')
      if self.environment
        cve = ContentViewEnvironment.where(:environment_id => self.environment,
                                           :content_view_id => self.content_view).first
        "#{organization.label}/#{cve.label}/#{content_path}"
      else
        "#{organization.label}/#{ContentView::CONTENT_DIR}/#{self.content_view.label}/#{self.content_view_version.version}/#{content_path}"
      end
    end

    def generate_docker_repo_path
      org = self.organization.label.downcase
      if self.environment
        cve = ContentViewEnvironment.where(:environment_id => self.environment,
                                           :content_view_id => self.content_view).first
        view = self.content_view.label
        product = self.product.label
        env = cve.label.split('/').first
        "#{org}-#{env.downcase}-#{view}-#{product}-#{self.root.label}"
      else
        "#{org}-#{self.content_view.label}-#{self.content_view_version.version}-#{self.root.product.label}-#{self.root.label}"
      end
    end

    def packages_without_errata
      if errata_filenames.any?
        self.rpms.where("#{Rpm.table_name}.filename NOT in (?)", errata_filenames)
      else
        self.rpms
      end
    end

    def module_streams_without_errata
      module_stream_errata = Katello::ModuleStreamErratumPackage.joins(:erratum_package => {:erratum => :repository_errata})
                              .where("#{RepositoryErratum.table_name}.repository_id" => self.id)
                              .pluck("#{Katello::ModuleStreamErratumPackage.table_name}.module_stream_id")
      if module_stream_errata.any?
        self.module_streams.where("#{ModuleStream.table_name}.id NOT in (?)", module_stream_errata)
      else
        self.module_streams
      end
    end

    def self.with_errata(errata)
      joins(:repository_errata).where("#{Katello::RepositoryErratum.table_name}.erratum_id" => errata)
    end

    def errata_filenames
      Katello::ErratumPackage.joins(:erratum => :repository_errata).
          where("#{RepositoryErratum.table_name}.repository_id" => self.id).pluck("#{Katello::ErratumPackage.table_name}.filename")
    end

    # TODO: break up method
    def build_clone(options)
      to_env       = options[:environment]
      version      = options[:version]
      content_view = options[:content_view] || to_env.default_content_view
      to_version   = version || content_view.version(to_env)

      fail _("Cannot clone into the Default Content View") if content_view.default?

      if to_env && version
        fail "Cannot clone into both an environment and a content view version archive"
      end

      if to_version.nil?
        fail _("View %{view} has not been promoted to %{env}") %
                  {:view => content_view.name, :env => to_env.name}
      end

      if to_env && self.clones.in_content_views([content_view]).in_environment(to_env).any?
        fail _("Repository has already been cloned to %{cv_name} in environment %{to_env}") %
                  {:to_env => to_env, :cv_name => content_view.name}
      end

      if self.yum?
        if self.library_instance?
          checksum_type = root.checksum_type || pulp_scratchpad_checksum_type
        else
          checksum_type = self.saved_checksum_type
        end
      end
      clone = Repository.new(:environment => to_env,
                     :library_instance => library_instance_or_self,
                     :root => self.root,
                     :content_view_version => to_version,
                     :saved_checksum_type => checksum_type)

      clone.relative_path = clone.docker? ? clone.generate_docker_repo_path : clone.generate_repo_path
      clone
    end

    def latest_sync_audit
      self.audits.where(:action => AUDIT_SYNC_ACTION).order(:created_at).last
    end

    def cancel_dynflow_sync
      if latest_dynflow_sync
        plan = latest_dynflow_sync.execution_plan

        plan.steps.each_pair do |_number, step|
          if step.cancellable? && step.is_a?(Dynflow::ExecutionPlan::Steps::RunStep)
            ::ForemanTasks.dynflow.world.event(plan.id, step.id, Dynflow::Action::Cancellable::Cancel)
          end
        end
      end
    end

    def latest_dynflow_sync
      @latest_dynflow_sync ||= ForemanTasks::Task::DynflowTask.where(:label => ::Actions::Katello::Repository::Sync.name).
                                for_resource(self).order(:started_at).last
    end

    # returns other instances of this repo with the same library
    # equivalent of repo
    def environmental_instances(view)
      self.all_instances.non_archived.in_content_views([view])
    end

    def archived_instance
      if self.environment_id.nil? || self.library_instance_id.nil?
        self
      else
        self.content_view_version.archived_repos.where(:root_id => self.root_id).first
      end
    end

    def requires_yum_clone_distributor?
      self.yum? && self.environment_id && !self.in_default_view?
    end

    def url?
      root.url.present?
    end

    def name_conflicts
      if puppet?
        modules = PuppetModule.search("*", :repoids => self.pulp_id,
                                           :fields => [:name],
                                           :page_size => self.puppet_modules.count)

        modules.map(&:name).group_by(&:to_s).select { |_, v| v.size > 1 }.keys
      else
        []
      end
    end

    def related_resources
      self.product
    end

    def node_syncable?
      environment
    end

    def exist_for_environment?(environment, content_view, attribute = nil)
      if environment.present? && content_view.in_environment?(environment)
        repos = content_view.version(environment).repos(environment)

        repos.any? do |repo|
          not_self = (repo.id != self.id)
          same_product = (repo.product.id == self.product.id)

          repo_exists = same_product && not_self

          if repo_exists && attribute
            same_attribute = repo.send(attribute) == self.send(attribute)
            repo_exists = same_attribute
          end

          repo_exists
        end
      else
        false
      end
    end

    def ostree_branch_names
      self.ostree_branches.map(&:name)
    end

    def units_for_removal(ids, type_class = nil)
      removable_unit_association = unit_type_for_removal(type_class)
      table_name = removable_unit_association.table_name
      is_integer = Integer(ids.first) rescue false #assume all ids are either integers or not

      if is_integer
        removable_unit_association.where("#{table_name}.id in (?)", ids)
      else
        removable_unit_association.where("#{table_name}.pulp_id in (?)", ids)
      end
    end

    def self.import_distributions
      self.all.each do |repo|
        repo.import_distribution_data
      end
    end

    def import_distribution_data(target_repo = nil)
      if target_repo
        self.update!(
          :distribution_version => target_repo.distribution_version,
          :distribution_arch => target_repo.distribution_arch,
          :distribution_family => target_repo.distribution_family,
          :distribution_variant => target_repo.distribution_variant,
          :distribution_uuid => target_repo.distribution_uuid,
          :distribution_bootable => target_repo.distribution_bootable
        )
      else
        self.backend_service(SmartProxy.pulp_master).import_distribution_data
      end
    end

    def distribution_information
      {
        distribution_version: self.distribution_version,
        distribution_arch: self.distribution_arch,
        distribution_family: self.distribution_family,
        distribution_variant: self.distribution_variant,
        distribution_uuid: self.distribution_uuid,
        distribution_bootable: self.distribution_bootable
      }
    end

    def check_duplicate_branch_names(branch_names)
      dupe_branch_checker = {}
      dupe_branch_checker.default = 0
      branch_names.each do |branch|
        dupe_branch_checker[branch] += 1
      end

      duplicate_branch_names = dupe_branch_checker.select { |_, value| value > 1 }.keys

      unless duplicate_branch_names.empty?
        fail ::Katello::Errors::ConflictException,
              _("Duplicate branches specified - %{branches}") % { branches: duplicate_branch_names.join(", ")}
      end
    end

    # deleteable? is already taken by the authorization mixin
    def destroyable?
      if self.environment.try(:library?) && self.content_view.default?
        if self.environment.organization.being_deleted?
          return true
        elsif self.custom? && self.deletable?
          return true
        elsif !self.custom? && self.redhat_deletable?
          return true
        else
          errors.add(:base, _("Repository cannot be deleted since it has already been included in a published Content View. " \
                              "Please delete all Content View versions containing this repository before attempting to delete it."))

          return false
        end
      end
      return true
    end

    def sync_hook
      run_callbacks :sync do
        logger.debug "custom hook after_sync on #{name} will be executed if defined."
        true
      end
    end

    def rabl_path
      "katello/api/v2/#{self.class.to_s.demodulize.tableize}/show"
    end

    def assert_deletable
      throw :abort unless destroyable?
    end

    def hosts_with_applicability
      ::Host.joins(:content_facet => :bound_repositories).where("#{Katello::Repository.table_name}.id" => (self.clones.pluck(:id) + [self.id]))
    end

    def docker_meta_tag_count
      DockerMetaTag.in_repositories(self.id).count
    end

    # a master repository actually has content (rpms, errata, etc) in the pulp repository.  For these repositories, we can use the YumDistributor
    # to generate metadata and can index the content from pulp, or for the case of content view archives without filters, can also use the YumCloneDistributor
    #
    def master?
      !self.yum? || # non-yum repos
          self.in_default_view? || # default content view repos
          (self.archive? && !self.content_view.composite) || # non-composite content view archive repos
          (self.archive? && self.content_view.composite? && self.component_source_repositories.count > 1) # composite archive repo with more than 1 source repository
    end

    # a link repository has no content in the pulp repository and serves as a shell.  It will always be empty.  Only the YumCloneDistributor can be used
    # to publish yum metadata, and it cannot be indexed from pulp, but must have its indexed associations copied from another repository (its target).
    def link?
      !master?
    end

    # A link (empty repo) points to a target (a repository that actually has units in pulp).  Target repos are always archive repos of a content view version (a repo with no environment)
    # But for composite view versions, an archive repo, usually won't be a master (but might be if multple components contain the same repo)
    def target_repository
      fail _("This is not a linked repository") if master?
      return nil if self.archived_instance.nil?

      #this is an environment repo, and the archived_instance is a master (not always true with composite)
      if self.environment_id? && self.archived_instance.master?
        self.archived_instance
      elsif self.environment_id #this is an environment repo, but a composite who's archived_instance isn't a master
        self.archived_instance.target_repository || self.archived_instance #to archived_instance if nil
      else #must be a composite archive repo, with only one component repo
        self.component_source_repositories.first
      end
    end

    def component_source_repositories
      #find other copies of this repositories, in the CV version's components, that are in the 'archive'
      Katello::Repository.where(:content_view_version_id => self.content_view_version.components, :environment_id => nil,
                                :root_id => self.root_id)
    end

    def self.linked_repositories
      to_return = []
      Katello::Repository.yum_type.in_non_default_view.find_each do |repo|
        to_return << repo if repo.link?
      end
      to_return
    end

    def self.search_by_redhat(_key, operator, value)
      value = value == 'true'
      value = !value if operator == '<>'

      product_ids = Katello::Product.redhat.select(:id)
      root_ids = Katello::RootRepository.where(:product_id => product_ids).pluck(:id)
      if product_ids.empty?
        {:conditions => "1=0"}
      else
        operator = value ? 'IN' : 'NOT IN'
        {:conditions => "#{Katello::Repository.table_name}.root_id #{operator} (#{root_ids.join(',')})"}
      end
    end

    def self.search_by_content_label(_key, operator, value)
      conditions = sanitize_sql_for_conditions(["label #{operator} ?", value_to_sql(operator, value)])
      contents = Katello::Content.where(conditions).pluck(:cp_content_id)
      root_ids = Katello::RootRepository.where(:content_id => contents).pluck(:id)
      if root_ids.empty?
        { :conditions => "1=0" }
      else
        { :conditions => "#{Katello::Repository.table_name}.root_id IN (#{root_ids.join(',')})" }
      end
    end

    def self.safe_render_container_name(repository, pattern = nil)
      if (pattern && !pattern.blank?) || (repository.environment && !repository.environment.registry_name_pattern.empty?)
        pattern ||= repository.environment.registry_name_pattern
        allowed_methods = {}
        allowed_vars = {}
        scope_variables = {repository: repository, organization: repository.organization, product: repository.product,
                           lifecycle_environment: repository.environment, content_view: repository.content_view_version.content_view,
                           content_view_version: repository.content_view_version}
        box = Safemode::Box.new(repository, allowed_methods)
        erb = ERB.new(pattern)
        pattern = box.eval(erb.src, allowed_vars, scope_variables)
        return Repository.clean_container_name(pattern)
      elsif repository.content_view.default?
        items = [repository.organization.label, repository.product.label, repository.label]
      elsif repository.environment
        items = [repository.organization.label, repository.environment.label, repository.content_view.label, repository.product.label, repository.label]
      else
        items = [repository.organization.label, repository.content_view.label, repository.content_view_version.version, repository.product.label, repository.label]
      end
      Repository.clean_container_name(items.compact.join("-"))
    end

    def self.clean_container_name(name)
      name.gsub(/[^-\/\w]/, "_").gsub(/_{3,}/, "_").gsub(/-_|^_+|_+$/, "").downcase.strip
    end

    def custom_repo_path
      return custom_docker_repo_path if docker?
      if [environment, product, root.label].any?(&:nil?)
        return nil # can't generate valid path
      end
      prefix = [environment.organization.label, environment.label].map { |x| x.gsub(/[^-\w]/, "_") }.join("/")
      prefix + root.custom_content_path
    end

    def custom_docker_repo_path
      if [environment, product, root.label].any?(&:nil?)
        return nil # can't generate valid path
      end
      parts = [environment.organization.label, product.label, root.label]
      parts.map { |x| x.gsub(/[^-\w]/, "_") }.join("-").downcase
    end

    def repository_type
      RepositoryTypeManager.find(self.content_type)
    end

    def copy_indexed_data(source_repository)
      repository_type.content_types_to_index.each do |type|
        type.model_class.copy_repository_associations(source_repository, self)
        repository_type.index_additional_data_proc&.call(self, source_repository)
      end
    end

    def index_linked_repo
      if (base_repo = self.target_repository)
        copy_indexed_data(base_repo)
      else
        Rails.logger.error("Cannot index #{self.id}, no target repository found.")
      end
    end

    def index_content(options = {})
      source_repository = options.fetch(:source_repository, nil)

      if self.yum? && !self.master?
        index_linked_repo
      elsif source_repository && !repository_type.unique_content_per_repo
        copy_indexed_data(source_repository)
      else
        repository_type.content_types_to_index.each do |type|
          type.model_class.import_for_repository(self)
        end
        repository_type.index_additional_data_proc&.call(self)
      end
      true
    end

    def in_content_view?(content_view)
      content_view.repositories.include? self
    end

    protected

    def unit_type_for_removal(type_class = nil)
      if type_class
        Katello::RepositoryTypeManager.find_content_type(type_class).model_class
      else
        Katello::RepositoryTypeManager.find(self.content_type).default_managed_content_type.model_class
      end
    end

    def downcase_pulp_id
      # Docker doesn't support uppercase letters in repository names.  Since the pulp_id
      # is currently being used for the name, it will be downcased for this content type.
      if self.content_type == Repository::DOCKER_TYPE
        self.pulp_id = self.pulp_id.downcase
      end
    end

    def remove_docker_content(manifests)
      destroyable_manifests = manifests.select do |manifest|
        manifest.repositories.empty? || manifest.docker_manifest_lists.empty?
      end
      # destroy any orphan docker manifests
      destroyable_manifests.each do |manifest|
        self.docker_manifests.delete(manifest)
        manifest.destroy
      end
      DockerMetaTag.cleanup_tags
    end

    class Jail < ::Safemode::Jail
      allow :name, :label, :docker_upstream_name
    end
  end
end
