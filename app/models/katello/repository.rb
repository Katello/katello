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

    include Glue
    include Authorization::Repository
    include Katello::Engine.routes.url_helpers

    include ERB::Util
    include ::ScopedSearchExtensions

    AUDIT_SYNC_ACTION = 'sync'.freeze

    DEB_TYPE = 'deb'.freeze
    YUM_TYPE = 'yum'.freeze
    FILE_TYPE = 'file'.freeze
    DOCKER_TYPE = 'docker'.freeze
    OSTREE_TYPE = 'ostree'.freeze
    ANSIBLE_COLLECTION_TYPE = 'ansible_collection'.freeze
    GENERIC_TYPE = 'generic'.freeze

    EXPORTABLE_TYPES = [YUM_TYPE, FILE_TYPE, ANSIBLE_COLLECTION_TYPE, DOCKER_TYPE, DEB_TYPE].freeze

    ALLOWED_UPDATE_FIELDS = ['version_href', 'last_indexed'].freeze

    define_model_callbacks :sync, :only => :after

    belongs_to :root, :inverse_of => :repositories, :class_name => "Katello::RootRepository"
    belongs_to :environment, :inverse_of => :repositories, :class_name => "Katello::KTEnvironment"
    belongs_to :library_instance, :class_name => "Katello::Repository", :inverse_of => :library_instances_inverse
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

    has_many :repository_generic_content_units, :class_name => "Katello::RepositoryGenericContentUnit", :dependent => :delete_all
    has_many :generic_content_units, :through => :repository_generic_content_units

    has_many :repository_file_units, :class_name => "Katello::RepositoryFileUnit", :dependent => :delete_all
    has_many :files, :through => :repository_file_units, :source => :file_unit
    alias_attribute :file_units, :files

    has_many :repository_docker_manifests, :class_name => "Katello::RepositoryDockerManifest", :dependent => :delete_all
    has_many :docker_manifests, :through => :repository_docker_manifests

    has_many :repository_docker_manifest_lists, :class_name => "Katello::RepositoryDockerManifestList", :dependent => :delete_all
    has_many :docker_manifest_lists, :through => :repository_docker_manifest_lists

    has_many :yum_metadata_files, :dependent => :destroy, :class_name => "Katello::YumMetadataFile"

    has_many :repository_docker_tags, :class_name => "Katello::RepositoryDockerTag", :dependent => :delete_all
    has_many :docker_tags, :through => :repository_docker_tags

    has_many :repository_docker_meta_tags, :class_name => "Katello::RepositoryDockerMetaTag", :dependent => :delete_all
    has_many :docker_meta_tags, :through => :repository_docker_meta_tags

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
    has_many :distribution_references, :class_name => 'Katello::Pulp3::DistributionReference',
             :dependent => :destroy, :inverse_of => :repository

    has_many :smart_proxy_sync_histories, :class_name => "::Katello::SmartProxySyncHistory", :inverse_of => :repository, :dependent => :delete_all

    has_many :smart_proxy_alternate_content_sources, :class_name => 'Katello::SmartProxyAlternateContentSource', :inverse_of => :repository, :dependent => :nullify

    validates_with Validators::ContainerImageNameValidator, :attributes => :container_repository_name, :allow_blank => false, :if => :docker?
    validates :container_repository_name, :if => :docker?, :uniqueness => {message: ->(object, _data) do
      _("for repository '%{name}' is not unique and cannot be created in '%{env}'. Its Container Repository Name (%{container_name}) conflicts with an existing repository.  Consider changing the Lifecycle Environment's Registry Name Pattern to something more specific.") %
          {name: object.name, container_name: object.container_repository_name, :env => object.environment.name}
    end}

    before_validation :set_pulp_id
    before_validation :set_container_repository_name, :unless => :skip_container_name?
    before_update :prevent_updates, :unless => :allow_updates?

    scope :has_url, -> { joins(:root).where.not("#{RootRepository.table_name}.url" => nil) }
    scope :not_uln, -> { joins(:root).where("#{RootRepository.table_name}.url NOT LIKE 'uln%'") }
    scope :on_demand, -> { joins(:root).where("#{RootRepository.table_name}.download_policy" => ::Katello::RootRepository::DOWNLOAD_ON_DEMAND) }
    scope :immediate, -> { joins(:root).where("#{RootRepository.table_name}.download_policy" => ::Katello::RootRepository::DOWNLOAD_IMMEDIATE) }
    scope :non_immediate, -> { joins(:root).where.not("#{RootRepository.table_name}.download_policy" => ::Katello::RootRepository::DOWNLOAD_IMMEDIATE) }
    scope :in_default_view, -> { joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => true) }
    scope :in_non_default_view, -> { joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => false) }
    scope :deb_type, -> { with_type(DEB_TYPE) }
    scope :yum_type, -> { with_type(YUM_TYPE) }
    scope :file_type, -> { with_type(FILE_TYPE) }
    scope :docker_type, -> { with_type(DOCKER_TYPE) }
    scope :ostree_type, -> { with_type(OSTREE_TYPE) }
    scope :ansible_collection_type, -> { with_type(ANSIBLE_COLLECTION_TYPE) }
    scope :generic_type, -> { with_type(Katello::RepositoryTypeManager.enabled_repository_types.select { |_, v| v.pulp3_service_class == Katello::Pulp3::Repository::Generic }.keys) }
    scope :non_archived, -> { where('environment_id is not NULL') }
    scope :archived, -> { where('environment_id is NULL') }
    scope :in_published_environments, -> { in_content_views(Katello::ContentView.non_default).where.not(:environment_id => nil) }
    scope :order_by_root, ->(attr) { joins(:root).order("#{Katello::RootRepository.table_name}.#{attr}") }
    scope :with_content, ->(content) { joins(Katello::RepositoryTypeManager.find_content_type(content).model_class.repository_association_class.name.demodulize.underscore.pluralize.to_sym).distinct }
    scope :by_rpm_count, -> { left_joins(:repository_rpms).group(:id).order("count(katello_repository_rpms.id) ASC") } # smallest count first
    scope :immediate_or_none, -> do
      immediate.or(where("#{RootRepository.table_name}.download_policy" => nil)).
        or(where("#{RootRepository.table_name}.download_policy" => ""))
    end
    scope :redhat, -> { joins(:product => :provider).where("#{Provider.table_name}.provider_type": Provider::REDHAT) }
    scope :custom, -> { joins(:product => :provider).where.not("#{Provider.table_name}.provider_type": Provider::REDHAT) }
    scope :library, -> { where(library_instance_id: nil) }

    scoped_search :on => :name, :relation => :root, :complete_value => true
    scoped_search :rename => :product, :on => :name, :relation => :product, :complete_value => true
    scoped_search :rename => :product_id, :on => :id, :relation => :product
    scoped_search :on => :content_type, :relation => :root, :complete_value => -> do
      Katello::RepositoryTypeManager.enabled_repository_types.keys.index_by { |value| value.to_sym }
    end
    scoped_search :on => :content_view_id, :relation => :content_view_repositories, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :distribution_version, :complete_value => true
    scoped_search :on => :distribution_arch, :complete_value => true
    scoped_search :on => :distribution_family, :complete_value => true
    scoped_search :on => :distribution_variant, :complete_value => true
    scoped_search :on => :distribution_bootable, :complete_value => true
    scoped_search :on => :redhat, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_redhat
    scoped_search :on => :container_repository_name, :complete_value => true
    scoped_search :on => :description, :relation => :root, :only_explicit => true
    scoped_search :on => :download_policy, :relation => :root, :only_explicit => true
    scoped_search :on => :name, :relation => :product, :rename => :product_name
    scoped_search :on => :id, :relation => :product, :rename => :product_id, :only_explicit => true
    scoped_search :on => :label, :relation => :root, :complete_value => true, :only_explicit => true
    scoped_search :on => :content_label, :ext_method => :search_by_content_label, :default_operator => :like

    delegate :product, :redhat?, :custom?, :deb_using_structured_apt?, :to => :root
    delegate :yum?, :docker?, :deb?, :file?, :ostree?, :ansible_collection?, :generic?, :to => :root
    delegate :name, :label, :docker_upstream_name, :url, :download_concurrency, :to => :root

    delegate :name, :created_at, :updated_at, :major, :minor, :gpg_key_id, :gpg_key, :arch, :label, :url, :unprotected,
             :content_type, :product_id, :checksum_type, :docker_upstream_name, :mirroring_policy,
             :download_policy, :verify_ssl_on_sync, :"verify_ssl_on_sync?", :upstream_username, :upstream_password,
             :upstream_authentication_token, :deb_releases,
             :deb_components, :deb_architectures, :ssl_ca_cert_id, :ssl_ca_cert, :ssl_client_cert, :ssl_client_cert_id,
             :ssl_client_key_id, :os_versions, :ssl_client_key, :ignorable_content, :description, :include_tags, :exclude_tags,
             :ansible_collection_requirements, :ansible_collection_auth_url, :ansible_collection_auth_token,
             :http_proxy_policy, :http_proxy_id, :prevent_updates, :to => :root

    delegate :repository_type, to: :root

    def self.exportable_types(format: ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE)
      return [YUM_TYPE, FILE_TYPE] if format == ::Katello::Pulp3::ContentViewVersion::Export::SYNCABLE
      EXPORTABLE_TYPES
    end

    def self.exportable(format: ::Katello::Pulp3::ContentViewVersion::Export::IMPORTABLE)
      with_type(exportable_types(format: format))
    end

    def self.with_type(content_type)
      joins(:root).where("#{RootRepository.table_name}.content_type" => content_type)
    end

    def self.for_products(products)
      joins(:root).where("#{Katello::RootRepository.table_name}.product_id" => products)
    end

    def self.repo_path_from_content_path(environment, content_path)
      path = content_path.sub(%r|^/|, '')
      path_prefix = [environment.organization.label, environment.label].join('/')
      "#{path_prefix}/#{path}"
    end

    def content_id
      # Currently deb content will store a content_id on each Repository, while all other content
      # types will store one on the RootRepository.
      self[:content_id] || root.content_id
    end

    def content
      Katello::Content.find_by(:cp_content_id => self.content_id, :organization_id => self.product.organization_id)
    end

    def to_label
      name
    end

    def backend_service(smart_proxy)
      fail('Pulp 3 not supported') unless smart_proxy.pulp3_support?(self)

      @service ||= Katello::Pulp3::Repository.instance_for_type(self, smart_proxy)
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

    def self.attribute_name
      :name
    end

    def set_container_repository_name
      self.container_repository_name = Repository.safe_render_container_name(self)
    end

    def content_view
      self.content_view_version.content_view
    end

    def content_view_environment
      self.content_view.content_view_environment(self.environment)
    end

    # Skip setting container name if the repository is not container type or
    # if it's a library instance of a container-push repo, indicating that the container name is set by the user.
    def skip_container_name?
      !self.root.docker? || (self.root.is_container_push && self.library_instance?)
    end

    def library_instance?
      self.content_view.default?
    end

    def self.undisplayable_types
      [::Katello::Repository::CANDLEPIN_DOCKER_TYPE]
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

    def soft_copy_of_library?
      return false if self.version_href.nil?
      self.version_href.starts_with?(self.library_instance.backend_service(SmartProxy.pulp_primary).repository_reference.repository_href)
    end

    def archive?
      self.environment.nil?
    end

    def using_mirrored_metadata?
      self.yum? && self.library_instance? && self.root.mirroring_policy == Katello::RootRepository::MIRRORING_POLICY_COMPLETE
    end

    def in_default_view?
      content_view_version&.default_content_view?
    end

    def on_demand?
      root.download_policy == ::Katello::RootRepository::DOWNLOAD_ON_DEMAND
    end

    def immediate?
      root.download_policy == ::Katello::RootRepository::DOWNLOAD_IMMEDIATE
    end

    def yum_gpg_key_url
      # if the repo has a gpg key return a url to access it
      if self.root.gpg_key.try(:content).present?
        "../..#{gpg_key_content_api_repository_url(self, :only_path => true)}"
      end
    end

    def full_gpg_key_path(smart_proxy = nil, force_http = false)
      return if self.root.gpg_key.try(:content).blank?
      pulp_uri = URI.parse(smart_proxy ? smart_proxy.url : ::SmartProxy.pulp_primary.url)
      scheme = force_http ? 'http' : 'https'
      "#{scheme}://#{pulp_uri.host.downcase}#{gpg_key_content_api_repository_url(self, :only_path => true)}"
    end

    def product_type
      redhat? ? "redhat" : "custom"
    end

    def content_counts
      content_counts = {}
      RepositoryTypeManager.defined_repository_types[content_type].content_types_to_index.each do |content_type|
        case content_type&.model_class::CONTENT_TYPE
        when DockerTag::CONTENT_TYPE
          content_counts[DockerTag::CONTENT_TYPE] = docker_tags.count
        when GenericContentUnit::CONTENT_TYPE
          content_counts[content_type.content_type] = content_type&.model_class&.in_repositories(self)&.where(:content_type => content_type.content_type)&.count
        else
          content_counts[content_type.label] = content_type&.model_class&.in_repositories(self)&.count
        end
      end

      content_counts['module_stream'] = content_counts.delete('modulemd') if content_counts.key?('modulemd')
      content_counts
    end

    def published_in_versions
      Katello::ContentViewVersion.with_repositories(self.library_instances_inverse)
                                 .where(content_view_id: Katello::ContentView.ignore_generated).distinct
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

    def full_path(smart_proxy = nil, force_http = false)
      pulp_uri = URI.parse(smart_proxy ? smart_proxy.url : ::SmartProxy.pulp_primary.url)
      scheme = force_http ? 'http' : 'https'
      if docker?
        "#{pulp_uri.host.downcase}/#{container_repository_name}"
      elsif ansible_collection?
        "#{scheme}://#{pulp_uri.host.downcase}/pulp_ansible/galaxy/#{relative_path}/api/"
      else
        "#{scheme}://#{pulp_uri.host.downcase}/pulp/content/#{relative_path}/"
      end
    end

    def to_hash(content_source = nil, force_http = false)
      {id: id, name: label, url: full_path(content_source, force_http)}
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
        "#{org}/#{env.downcase}/#{view}/#{product}/#{self.root.label}"
      else
        "#{org}/#{self.content_view.label}/#{self.content_view_version.version}/#{self.root.product.label}/#{self.root.label}"
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
          checksum_type = root.checksum_type
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

    def self.synced_on_capsule(smart_proxy)
      smart_proxy.smart_proxy_sync_histories.map { |sph| sph.repository unless sph.finished_at.nil? }
    end

    def clear_smart_proxy_sync_histories(smart_proxy = nil)
      if smart_proxy
        self.smart_proxy_sync_histories.where(:smart_proxy_id => smart_proxy.id).try(:delete_all)
      else
        self.smart_proxy_sync_histories.delete_all
      end
    end

    def create_smart_proxy_sync_history(smart_proxy)
      clear_smart_proxy_sync_histories(smart_proxy)
      sp_history_args = {
        :smart_proxy_id => smart_proxy.id,
        :repository_id => self.id,
        :started_at => Time.now,
      }
      sp_history = ::Katello::SmartProxySyncHistory.create sp_history_args
      sp_history.save!
      sp_history.id
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

    def blocking_task
      blocking_task_labels = [
        ::Actions::Katello::Repository::Sync.name,
        ::Actions::Katello::Repository::UploadFiles.name,
        ::Actions::Katello::Repository::RemoveContent.name,
        ::Actions::Katello::Repository::MetadataGenerate.name,
      ]
      ForemanTasks::Task::DynflowTask.where(:label => blocking_task_labels)
                                     .where.not(state: 'stopped')
                                     .for_resource(self)
                                     .order(:started_at)
                                     .last
    end

    def check_ready_to_act!
      blocking_tasks = content_views&.map { |cv| cv.blocking_task }&.compact

      if blocking_tasks&.any?
        errored_tasks = blocking_tasks
                          .uniq
                          .map { |task| "- #{Setting['foreman_url']}/foreman_tasks/tasks/#{task&.id}" }
                          .join("\n")
        fail _("Repository #{self.label} has pending tasks in associated content views. Please wait for the tasks: " + errored_tasks +
               " to complete before proceeding.")
      end
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

    def related_resources
      self.product
    end

    def node_syncable?
      environment
    end

    def self.smart_proxy_syncable
      joins(:content_view_version => :content_view).
        merge(ContentView.ignore_generated(include_library_generated: true)).
        where.not(environment_id: nil)
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
          :distribution_bootable => target_repo.distribution_bootable
        )
      else
        self.backend_service(SmartProxy.pulp_primary).import_distribution_data
      end
    end

    def distribution_information
      {
        distribution_version: self.distribution_version,
        distribution_arch: self.distribution_arch,
        distribution_family: self.distribution_family,
        distribution_variant: self.distribution_variant,
        distribution_bootable: self.distribution_bootable,
      }
    end

    # deleteable? is already taken by the authorization mixin
    def destroyable?(remove_from_content_view_versions = false)
      if self.environment.try(:library?) && self.content_view.default?
        if self.environment.organization.being_deleted?
          return true
        elsif self.custom? && self.deletable?(remove_from_content_view_versions)
          return true
        elsif !self.custom? && self.redhat_deletable?(remove_from_content_view_versions)
          return true
        elsif Setting.find_by(name: 'delete_repo_across_cv')&.value
          return true
        else
          errors.add(:base, _("Repository cannot be deleted since it has already been included in a published Content View. " \
                              "Please delete all Content View versions containing this repository before attempting to delete it "\
                              "or use --remove-from-content-view-versions flag to automatically remove the repository from all published versions."))

          return false
        end
      end
      return true
    end

    def content_views_all(include_composite: false)
      if include_composite
        cv_ids = library_instances_inverse&.joins(:content_view_version)&.map { |cvv| cvv&.content_view&.id }
        return ContentView.where(id: cv_ids.uniq)
      else
        return self.content_views
      end
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

    def docker_meta_tag_count
      DockerMetaTag.in_repositories(self.id).count
    end

    # a primary repository actually has content (rpms, errata, etc) in the pulp repository.  For these repositories, we can use the YumDistributor
    # to generate metadata and can index the content from pulp, or for the case of content view archives without filters, can also use the YumCloneDistributor
    #
    def primary?
      !self.yum? || # non-yum repos
          self.in_default_view? || # default content view repos
          (self.archive? && !self.content_view.composite) || # non-composite content view archive repos
          (self.archive? && self.content_view.composite? && self.component_source_repositories.count > 1) # composite archive repo with more than 1 source repository
    end

    # a link repository has no content in the pulp repository and serves as a shell.  It will always be empty.  Only the YumCloneDistributor can be used
    # to publish yum metadata, and it cannot be indexed from pulp, but must have its indexed associations copied from another repository (its target).
    def link?
      !primary?
    end

    # A link (empty repo) points to a target (a repository that actually has units in pulp).  Target repos are always archive repos of a content view version (a repo with no environment)
    # But for composite view versions, an archive repo, usually won't be a primary (but might be if multple components contain the same repo)
    def target_repository
      fail _("This is not a linked repository") if primary?
      return nil if self.archived_instance.nil?

      #this is an environment repo, and the archived_instance is a primary (not always true with composite)
      if self.environment_id? && self.archived_instance.primary?
        self.archived_instance
      elsif self.environment_id #this is an environment repo, but a composite who's archived_instance isn't a primary
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
      #            pattern provided / env pattern provided
      #                 |  00 |  01 |  11 |  10
      # ----------------+-----+-----+-----+------
      # env exists /  00|   4 | n/a | n/a |   4
      # is cv default 01|   2 | n/a | n/a |   4
      #               11|   2 |   1 |   1 |   1
      #               10|   3 |   1 |   1 |   1
      #
      # This table shows the name to render given the properties of
      # the container provided. Branches numbered as ordered below.
      #
      # 1 - Render promotion pattern (or env pattern if no promo pattern)
      # 2 - <org label>/<product label>/<repo label>
      # 3 - <org label>/<env label>/<cv label>/<product label>/<repo label>
      # 4 - <org label>/<cv label>/<cvv label>/<product label>/<repo label>
      is_pattern_provided = pattern.present?
      env_exists = repository.environment.present?
      is_env_pattern_provided = env_exists && repository.environment.registry_name_pattern.present?
      is_cv_default = repository.content_view.default?

      if is_env_pattern_provided || (is_pattern_provided && env_exists)
        pattern ||= repository.environment.registry_name_pattern
        allowed_methods = {}
        allowed_vars = {}
        scope_variables = {
          repository: repository,
          organization: repository.organization,
          product: repository.product,
          lifecycle_environment: repository.environment,
          content_view: repository.content_view_version.content_view,
          content_view_version: repository.content_view_version,
        }
        box = Safemode::Box.new(repository, allowed_methods)
        erb = ERB.new(pattern)
        pattern = box.eval(erb.src, allowed_vars, scope_variables)
        return Repository.clean_container_name(pattern)
      elsif is_cv_default && !is_pattern_provided
        items = [repository.organization.label, repository.product.label, repository.label]
      elsif env_exists
        items = [repository.organization.label, repository.environment.label, repository.content_view.label, repository.product.label, repository.label]
      else
        items = [repository.organization.label, repository.content_view.label, repository.content_view_version.version, repository.product.label, repository.label]
      end
      Repository.clean_container_name(items.compact.join("/"))
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
      # set full_index to true if you want to force fetch all data from pulp
      # This is automatically done for library instance repos
      # However for non-library instance as in those belonging to a version
      # by default we fetch only ids and match them with the library instance
      # some times we want to force fetch all data even for non-library repos.
      # Use the full_index for those times

      full_index = options.fetch(:full_index, false)
      source_repository = options.fetch(:source_repository, nil)
      if self.yum? && !self.primary?
        index_linked_repo
      elsif source_repository && !repository_type.unique_content_per_repo
        copy_indexed_data(source_repository)
      else
        repository_type.content_types_to_index.each do |type|
          Katello::Logging.time("CONTENT_INDEX", data: {type: type.model_class}) do
            Katello::ContentUnitIndexer.new(content_type: type, repository: self, optimized: !full_index).import_all
          end
        end
        repository_type.index_additional_data_proc&.call(self)
      end
      self.update!(last_indexed: DateTime.now)

      true
    end

    def in_content_view?(content_view)
      content_view.repositories.include? self
    end

    def deb_content_url_options
      return '' unless version_href
      return '' if backend_service(SmartProxy.pulp_primary).version_missing_structure_content?

      components = deb_pulp_components.join(',')
      distributions = deb_pulp_distributions.join(',')
      "/?comp=#{components}&rel=#{distributions}"
    end

    def deb_pulp_components(version_href = self.version_href)
      return [] if version_href.blank?

      pulp_api = Katello::Pulp3::Repository.instance_for_type(self, SmartProxy.pulp_primary).api.content_release_components_api
      pulp_api.list({:repository_version => version_href}).results.map { |x| x.component }.uniq
    end

    def deb_sanitize_pulp_distribution(distribution)
      return "flat-repo" if distribution == "/"
      return distribution.chomp("/") if distribution&.end_with?("/")
      distribution
    end

    def deb_pulp_distributions(version_href = self.version_href)
      return [] if version_href.blank?
      pulp_api = Katello::Pulp3::Repository.instance_for_type(self, SmartProxy.pulp_primary).api.content_release_components_api
      pulp_api.list({:repository_version => version_href}).results.map { |x| deb_sanitize_pulp_distribution(x.distribution) }.uniq
    end

    def sync_status
      return latest_dynflow_sync
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

    def allow_updates?
      # allow the update if this repo is not in the default view
      return true unless in_default_view?
      root.allow_updates?(::Katello::Repository::ALLOWED_UPDATE_FIELDS)
    end

    apipie :class, desc: "A class representing #{model_name.human} object" do
      name 'Repository'
      refs 'Repository'
      sections only: %w[all additional]
      prop_group :katello_basic_props, Katello::Model, meta: { friendly_name: 'Repository' }
      property :docker_upstream_name, String, desc: 'Returns name of the upstream docker repository'
    end
    class Jail < ::Safemode::Jail
      allow :name, :label, :docker_upstream_name, :content_counts
    end
  end
end
