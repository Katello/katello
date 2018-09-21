module Katello
  # rubocop:disable Metrics/ClassLength
  class Repository < Katello::Model
    audited
    #pulp uses pulp id to sync with 'yum_distributor' on the end
    PULP_ID_MAX_LENGTH = 220

    serialize :docker_tags_whitelist

    validates_lengths_from_database :except => [:label]
    before_destroy :assert_deletable
    before_create :downcase_pulp_id
    before_validation :update_ostree_upstream_sync_policy
    serialize :ignorable_content

    include ForemanTasks::Concerns::ActionSubject
    include Glue::Candlepin::Repository
    include Glue::Pulp::Repo if SETTINGS[:katello][:use_pulp]

    include Glue if (SETTINGS[:katello][:use_cp] || SETTINGS[:katello][:use_pulp])
    include Authorization::Repository

    include Ext::LabelFromName
    include Katello::Engine.routes.url_helpers

    include ERB::Util

    DEB_TYPE = 'deb'.freeze
    YUM_TYPE = 'yum'.freeze
    FILE_TYPE = 'file'.freeze
    PUPPET_TYPE = 'puppet'.freeze
    DOCKER_TYPE = 'docker'.freeze
    OSTREE_TYPE = 'ostree'.freeze

    IGNORABLE_CONTENT_UNIT_TYPES = %w(rpm drpm srpm distribution erratum).freeze
    CHECKSUM_TYPES = %w(sha1 sha256).freeze
    SUBSCRIBABLE_TYPES = [YUM_TYPE, OSTREE_TYPE, DEB_TYPE].freeze

    OSTREE_UPSTREAM_SYNC_POLICY_LATEST = "latest".freeze
    OSTREE_UPSTREAM_SYNC_POLICY_ALL = "all".freeze
    OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM = "custom".freeze
    OSTREE_UPSTREAM_SYNC_POLICIES = [OSTREE_UPSTREAM_SYNC_POLICY_LATEST, OSTREE_UPSTREAM_SYNC_POLICY_ALL, OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM].freeze

    define_model_callbacks :sync, :only => :after

    belongs_to :environment, :inverse_of => :repositories, :class_name => "Katello::KTEnvironment"
    belongs_to :product, :inverse_of => :repositories, :class_name => "Katello::Product"
    belongs_to :gpg_key, :inverse_of => :repositories, :class_name => "Katello::GpgKey"
    belongs_to :ssl_ca_cert, :class_name => "Katello::GpgKey", :inverse_of => :ssl_ca_repos
    belongs_to :ssl_client_cert, :class_name => "Katello::GpgKey", :inverse_of => :ssl_client_repos
    belongs_to :ssl_client_key, :class_name => "Katello::GpgKey", :inverse_of => :ssl_key_repos
    belongs_to :library_instance, :class_name => "Katello::Repository", :inverse_of => :library_instances_inverse
    has_many :library_instances_inverse, # TODO: what is the proper name?
             :class_name  => 'Katello::Repository',
             :dependent   => :restrict_with_exception,
             :foreign_key => :library_instance_id
    has_many :content_view_repositories, :class_name => "Katello::ContentViewRepository",
                                         :dependent => :destroy, :inverse_of => :repository
    has_many :content_views, :through => :content_view_repositories

    has_many :repository_errata, :class_name => "Katello::RepositoryErratum", :dependent => :delete_all
    has_many :errata, :through => :repository_errata

    has_many :repository_rpms, :class_name => "Katello::RepositoryRpm", :dependent => :delete_all
    has_many :rpms, :through => :repository_rpms

    has_many :repository_srpms, :class_name => "Katello::RepositorySrpm", :dependent => :delete_all
    has_many :srpms, :through => :repository_srpms

    has_many :repository_files, :class_name => "Katello::RepositoryFile", :dependent => :destroy
    has_many :files, :through => :repository_files

    has_many :repository_puppet_modules, :class_name => "Katello::RepositoryPuppetModule", :dependent => :delete_all
    has_many :puppet_modules, :through => :repository_puppet_modules

    has_many :repository_docker_manifests, :class_name => "Katello::RepositoryDockerManifest", :dependent => :delete_all
    has_many :docker_manifests, :through => :repository_docker_manifests

    has_many :repository_docker_manifest_lists, :class_name => "Katello::RepositoryDockerManifestList", :dependent => :delete_all
    has_many :docker_manifest_lists, :through => :repository_docker_manifest_lists

    has_many :docker_tags, :dependent => :destroy, :class_name => "Katello::DockerTag"

    has_many :docker_meta_tags, :dependent => :destroy, :class_name => "Katello::DockerMetaTag"

    has_many :repository_ostree_branches, :class_name => "Katello::RepositoryOstreeBranch", :dependent => :delete_all
    has_many :ostree_branches, :through => :repository_ostree_branches

    has_many :repository_debs, :class_name => "Katello::RepositoryDeb", :dependent => :delete_all
    has_many :debs, :through => :repository_debs

    has_many :content_facet_repositories, :class_name => "Katello::ContentFacetRepository", :dependent => :destroy
    has_many :content_facets, :through => :content_facet_repositories

    has_many :repository_package_groups, :class_name => "Katello::RepositoryPackageGroup", :dependent => :delete_all
    has_many :package_groups, :through => :repository_package_groups

    has_many :kickstart_content_facets, :class_name => "Katello::Host::ContentFacet", :foreign_key => :kickstart_repository_id,
                          :inverse_of => :kickstart_repository, :dependent => :nullify

    has_many :kickstart_hostgroups, :class_name => "::Hostgroup", :foreign_key => :kickstart_repository_id,
             :inverse_of => :kickstart_repository, :dependent => :nullify

    has_many :repository_module_streams, class_name: "Katello::RepositoryModuleStream", dependent: :delete_all
    has_many :module_streams, through: :repository_module_streams

    # rubocop:disable HasAndBelongsToMany
    # TODO: change this into has_many :through association
    has_and_belongs_to_many :filters, :class_name => "Katello::ContentViewFilter",
                                      :join_table => :katello_content_view_filters_repositories,
                                      :foreign_key => :content_view_filter_id
    belongs_to :content_view_version, :inverse_of => :repositories, :class_name => "Katello::ContentViewVersion"

    validates :product_id, :presence => true
    validates :pulp_id, :presence => true, :uniqueness => true, :if => proc { |r| r.name.present? }
    validates :checksum_type, :inclusion => {:in => CHECKSUM_TYPES}, :allow_blank => true

    validates_with Validators::ContainerImageNameValidator, :attributes => :docker_upstream_name, :allow_blank => true, :if => :docker?
    validates_with Validators::ContainerImageNameValidator, :attributes => :container_repository_name, :allow_blank => false, :if => :docker?
    validates :container_repository_name, :uniqueness => true, :if => :docker?

    validates :ostree_upstream_sync_policy, :inclusion => {:in => OSTREE_UPSTREAM_SYNC_POLICIES, :allow_blank => true}, :if => :ostree?
    validates :ostree_upstream_sync_depth, :presence => true, :numericality => { :only_integer => true },
      :if => proc { |r| r.ostree? && r.ostree_upstream_sync_policy == OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM }
    #validates :content_id, :presence => true #add back after fixing add_repo orchestration
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::RepositoryUniqueAttributeValidator, :attributes => :label
    validates_with Validators::RepositoryUniqueAttributeValidator, :attributes => :name
    validates_with Validators::KatelloUrlFormatValidator,
      :attributes => :url, :nil_allowed => proc { |repo| repo.custom? }, :field_name => :url,
      :if => proc { |repo| repo.in_default_view? }
    validates :content_type, :inclusion => {
      :in => ->(_) { Katello::RepositoryTypeManager.repository_types.keys },
      :allow_blank => false,
      :message => ->(_, _) { _("must be one of the following: %s") % Katello::RepositoryTypeManager.repository_types.keys.join(', ') }
    }
    validates :download_policy, inclusion: {
      :in => ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES,
      :message => _("must be one of the following: %s") % ::Runcible::Models::YumImporter::DOWNLOAD_POLICIES.join(', ')
    }, if: :yum?
    validate :ensure_no_download_policy, if: ->(repo) { !repo.yum? }
    validate :ensure_no_ostree_upstream_sync_policy, if: ->(repo) { !repo.ostree? }
    validate :ensure_valid_docker_attributes, :if => :docker?
    validate :ensure_docker_repo_unprotected, :if => :docker?
    validate :ensure_has_url_for_ostree, :if => :ostree?
    validate :ensure_ostree_repo_protected, :if => :ostree?
    validate :ensure_compatible_download_policy, :if => :yum?
    validate :ensure_valid_ignorable_content
    validate :ensure_valid_upstream_authorization

    before_validation :set_pulp_id
    before_validation :set_container_repository_name, :if => :docker?

    scope :has_url, -> { where('url IS NOT NULL') }
    scope :in_default_view, -> { joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => true) }
    scope :in_non_default_view, -> { joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => false) }
    scope :deb_type, -> { where(:content_type => DEB_TYPE) }
    scope :yum_type, -> { where(:content_type => YUM_TYPE) }
    scope :file_type, -> { where(:content_type => FILE_TYPE) }
    scope :puppet_type, -> { where(:content_type => PUPPET_TYPE) }
    scope :docker_type, -> { where(:content_type => DOCKER_TYPE) }
    scope :ostree_type, -> { where(:content_type => OSTREE_TYPE) }
    scope :non_puppet, -> { where("content_type != ?", PUPPET_TYPE) }
    scope :non_archived, -> { where('environment_id is not NULL') }
    scope :archived, -> { where('environment_id is NULL') }
    scope :subscribable, -> { where(content_type: SUBSCRIBABLE_TYPES) }
    scope :in_published_environments, -> { in_content_views(Katello::ContentView.non_default).where.not(:environment_id => nil) }

    scoped_search :on => :name, :complete_value => true
    scoped_search :rename => :product, :on => :name, :relation => :product, :complete_value => true
    scoped_search :on => :content_type, :complete_value => -> do
      Katello::RepositoryTypeManager.repository_types.keys.each_with_object({}) { |value, hash| hash[value.to_sym] = value }
    end
    scoped_search :on => :content_view_id, :relation => :content_view_repositories, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :distribution_version, :complete_value => true
    scoped_search :on => :distribution_arch, :complete_value => true
    scoped_search :on => :distribution_family, :complete_value => true
    scoped_search :on => :distribution_variant, :complete_value => true
    scoped_search :on => :distribution_bootable, :complete_value => true
    scoped_search :on => :distribution_uuid, :complete_value => true
    scoped_search :on => :ignore_global_proxy, :complete_value => true
    scoped_search :on => :redhat, :complete_value => { :true => true, :false => false }, :ext_method => :search_by_redhat
    scoped_search :on => :container_repository_name, :complete_value => true
    scoped_search :on => :description, :only_explicit => true
    scoped_search :on => :name, :relation => :product, :rename => :product_name
    scoped_search :on => :id, :relation => :product, :rename => :product_id

    def organization
      if self.environment
        self.environment.organization
      else
        self.content_view.organization
      end
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
      where(product_id: prod)
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
      content_view_version && content_view_version.default_content_view?
    end

    def on_demand?
      download_policy == Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND
    end

    def self.in_environments_products(env_ids, product_ids)
      in_environment(env_ids).in_product(product_ids)
    end

    def other_repos_with_same_product_and_content
      Repository.in_product(Product.find(self.product.id)).where(:content_id => self.content_id)
          .where("#{self.class.table_name}.id != #{self.id}")
    end

    def other_repos_with_same_content
      Repository.where(:content_id => self.content_id).where("#{self.class.table_name}.id != #{self.id}")
    end

    def yum_gpg_key_url
      # if the repo has a gpg key return a url to access it
      if (self.gpg_key && self.gpg_key.content.present?)
        "../..#{gpg_key_content_api_repository_url(self, :only_path => true)}"
      end
    end

    def product_type
      redhat? ? "redhat" : "custom"
    end

    delegate :redhat?, to: :product

    def custom?
      !redhat?
    end

    def empty_errata
      repository_rpm = Katello::RepositoryRpm.table_name
      repository_errata = Katello::RepositoryErratum.table_name
      rpm = Katello::Rpm.table_name
      errata = Katello::Erratum.table_name
      erratum_package = Katello::ErratumPackage.table_name

      errata_with_packages = Erratum.joins(
        "INNER JOIN #{erratum_package} on #{erratum_package}.erratum_id = #{errata}.id",
        "INNER JOIN #{repository_errata} on #{repository_errata}.erratum_id = #{errata}.id",
        "INNER JOIN #{rpm} on #{rpm}.filename = #{erratum_package}.filename",
        "INNER JOIN #{repository_rpm} on #{repository_rpm}.rpm_id = #{rpm}.id").
        where("#{repository_rpm}.repository_id" => self.id).
        where("#{repository_errata}.repository_id" => self.id)

      if errata_with_packages.any?
        self.errata.where("#{Katello::Erratum.table_name}.id NOT IN (?)", errata_with_packages.pluck("#{errata}.id"))
      else
        self.errata
      end
    end

    def library_instance?
      library_instance.nil?
    end

    def clones
      lib_id = self.library_instance_id || self.id
      Repository.where(:library_instance_id => lib_id)
    end

    def group
      library_repo = library_instance? ? self : library_instance
      clones.to_a << library_repo
    end

    #is the repo cloned in the specified environment
    def cloned_in?(env)
      !get_clone(env).nil?
    end

    def promoted?
      if environment && environment.library? && Repository.where(:library_instance_id => self.id).any?
        true
      else
        false
      end
    end

    def get_clone(env)
      if self.content_view.default
        # this repo is part of a default content view
        lib_id = self.library_instance_id || self.id
        Repository.in_environment(env).where(:library_instance_id => lib_id).
            joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => true).first
      else
        # this repo is part of a content view that was published from a user created view
        self.content_view.get_repo_clone(env, self).first
      end
    end

    def gpg_key_name=(name)
      if name.blank?
        self.gpg_key = nil
      else
        self.gpg_key = GpgKey.readable.find_by!(:name => name)
      end
    end

    def copy_library_instance_attributes
      self.unprotected = library_instance.unprotected
      self.checksum_type = library_instance.checksum_type
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

    def as_json(*args)
      ret = super
      ret["gpg_key_name"] = gpg_key ? gpg_key.name : ""
      ret["package_count"] = package_count rescue nil
      ret["last_sync"] = last_sync rescue nil
      ret["puppet_module_count"] = self.puppet_modules.count rescue nil
      ret
    end

    def self.clone_repo_path(options)
      repo = options[:repository]
      repo_lib = repo.library_instance ? repo.library_instance : repo
      org, _, content_path = repo_lib.relative_path.split("/", 3)
      if options[:environment]
        cve = ContentViewEnvironment.where(:environment_id => options[:environment],
                                           :content_view_id => options[:content_view]).first
        "#{org}/#{cve.label}/#{content_path}"
      else
        "#{org}/#{ContentView::CONTENT_DIR}/#{options[:content_view].label}/#{options[:version].version}/#{content_path}"
      end
    end

    def self.clone_docker_repo_path(options)
      repo = options[:repository]
      org = repo.organization.label.downcase
      if options[:environment]
        cve = ContentViewEnvironment.where(:environment_id => options[:environment],
                                           :content_view_id => options[:content_view]).first
        view = repo.content_view.label
        product = repo.product.label
        env = cve.label.split('/').first
        "#{org}-#{env.downcase}-#{view}-#{product}-#{repo.label}"
      else
        content_path = repo.relative_path.gsub("#{org}-", '')
        "#{org}-#{options[:content_view].label}-#{options[:version].version}-#{content_path}"
      end
    end

    def packages_without_errata
      if errata_filenames.any?
        self.rpms.where("#{Rpm.table_name}.filename NOT in (?)", errata_filenames)
      else
        self.rpms
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
    # rubocop:disable MethodLength
    def build_clone(options)
      to_env       = options[:environment]
      version      = options[:version]
      content_view = options[:content_view] || to_env.default_content_view
      to_version   = version || content_view.version(to_env)
      library      = self.library_instance ? self.library_instance : self

      if to_env && version
        fail "Cannot clone into both an environment and a content view version archive"
      end

      if to_version.nil?
        fail _("View %{view} has not been promoted to %{env}") %
                  {:view => content_view.name, :env => to_env.name}
      end

      if content_view.default?
        if to_env.prior != self.environment
          fail _("Cannot clone repository from %{from_env} to %{to_env}. They are not sequential.") %
                    {:from_env => self.environment.name, :to_env => to_env.name}
        end
        if self.cloned_in?(to_env)
          fail _("Repository has already been promoted to %{to_env}") %
                  {:to_env => to_env}
        end
      else
        if to_env &&
            content_view.repos(to_env).where(:library_instance_id => library.id).count > 0
          fail _("Repository has already been cloned to %{cv_name} in environment %{to_env}") %
                    {:to_env => to_env, :cv_name => content_view.name}
        end
      end

      Repository.new(:environment => to_env,
                     :product => self.product,
                     :library_instance => library,
                     :label => self.label,
                     :name => self.name,
                     :arch => self.arch,
                     :major => self.major,
                     :minor => self.minor,
                     :content_id => self.content_id,
                     :content_view_version => to_version,
                     :content_type => self.content_type,
                     :checksum_type => checksum_type || source_repo_checksum_type,
                     :docker_upstream_name => self.docker_upstream_name,
                     :docker_tags_whitelist => self.docker_tags_whitelist,
                     :download_policy => download_policy,
                     :unprotected => self.unprotected) do |clone|
        options = {
          :repository => self,
          :environment => to_env,
          :content_view => content_view,
          :version => version
        }

        clone.relative_path = if clone.docker?
                                Repository.clone_docker_repo_path(options)
                              else
                                Repository.clone_repo_path(options)
                              end
      end
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

    def create_clone(options)
      clone = build_clone(options)
      clone.save!
      return clone
    end

    # returns other instances of this repo with the same library
    # equivalent of repo
    def environmental_instances(view)
      repo = self.library_instance || self
      search = Repository.non_archived.where("library_instance_id=%s or #{Katello::Repository.table_name}.id=%s" % [repo.id, repo.id])
      search.in_content_views([view])
    end

    def archived_instance
      if self.environment_id.nil? || self.library_instance_id.nil?
        self
      else
        self.content_view_version.archived_repos.where(:library_instance_id => self.library_instance_id).first
      end
    end

    def requires_yum_clone_distributor?
      self.yum? && self.environment_id && !self.in_default_view?
    end

    def url?
      url.present?
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

    def compute_ostree_upstream_sync_depth
      if ostree_upstream_sync_policy == OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM
        ostree_upstream_sync_depth
      elsif ostree_upstream_sync_policy == OSTREE_UPSTREAM_SYNC_POLICY_ALL
        -1
      else
        0
      end
    end

    def ostree_capsule_sync_depth
      -1
    end

    def units_for_removal(ids)
      table_name = removable_unit_association.table_name
      is_integer = Integer(ids.first) rescue false #assume all ids are either integers or not

      if is_integer
        self.removable_unit_association.where("#{table_name}.id in (?)", ids)
      else
        self.removable_unit_association.where("#{table_name}.uuid in (?)", ids)
      end
    end

    def self.import_distributions
      self.all.each do |repo|
        repo.import_distribution_data
      end
    end

    def import_distribution_data
      distribution = Katello.pulp_server.extensions.repository.distributions(self.pulp_id).first
      if distribution
        self.update_attributes!(
          :distribution_version => distribution["version"],
          :distribution_arch => distribution["arch"],
          :distribution_family => distribution["family"],
          :distribution_variant => distribution["variant"],
          :distribution_uuid => distribution["_id"],
          :distribution_bootable => ::Katello::Repository.distribution_bootable?(distribution)
        )
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

    def remove_content(units)
      if yum?
        self.rpms -= units
      elsif puppet?
        self.puppet_modules -= units
      elsif ostree?
        self.ostree_branches -= units
      elsif file?
        self.files -= units
      elsif deb?
        self.debs -= units
      elsif docker?
        remove_docker_content(units)
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
          (self.content_view.composite? && self.component_source_repositories.count > 1) # composite archive repo with more than 1 source repository
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
                                :library_instance_id => self.library_instance_id)
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

      product_ids = Katello::Product.redhat.pluck(:id)
      if product_ids.empty?
        {:conditions => "1=0"}
      else
        operator = value ? 'IN' : 'NOT IN'
        {:conditions => "#{Katello::Repository.table_name}.product_id #{operator} (#{product_ids.join(',')})"}
      end
    end

    def self.safe_render_container_name(repository, pattern = nil)
      if pattern || (repository.environment && !repository.environment.registry_name_pattern.empty?)
        pattern ||= repository.environment.registry_name_pattern
        allowed_methods = {}
        allowed_vars = {}
        scope_variables = {repository: repository, organization: repository.organization, product: repository.product,
                           lifecycle_environment: repository.environment, content_view: repository.content_view_version.content_view}
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

    protected

    def removable_unit_association
      if yum?
        self.rpms
      elsif docker?
        self.docker_manifests
      elsif puppet?
        self.puppet_modules
      elsif ostree?
        self.ostree_branches
      elsif file?
        self.files
      elsif deb?
        self.debs
      else
        fail "Content type not supported for removal"
      end
    end

    def downcase_pulp_id
      # Docker doesn't support uppercase letters in repository names.  Since the pulp_id
      # is currently being used for the name, it will be downcased for this content type.
      if self.content_type == Repository::DOCKER_TYPE
        self.pulp_id = self.pulp_id.downcase
      end
    end

    def ensure_compatible_download_policy
      if library_instance? && !url.blank? && URI(url).scheme == 'file' &&
          [::Runcible::Models::YumImporter::DOWNLOAD_ON_DEMAND, ::Runcible::Models::YumImporter::DOWNLOAD_BACKGROUND].include?(download_policy)
        errors.add(:download_policy, N_("Cannot sync file:// repositories with On Demand or Background Download Policies"))
      end
    end

    def ensure_valid_docker_attributes
      if library_instance? && (!url.blank? && docker_upstream_name.blank?)
        errors.add(:docker_upstream_name, N_("cannot be blank when Repository URL is provided."))
        errors.add(:base, N_("Upstream Name cannot be blank when Repository URL is provided."))
      end
    end

    def ensure_docker_repo_unprotected
      unless unprotected
        errors.add(:base, N_("Container Image Repositories are not protected at this time. " \
                             "They need to be published via http to be available to containers."))
      end
    end

    def ensure_no_download_policy
      if !yum? && download_policy.present?
        errors.add(:download_policy, N_("cannot be set for non-yum repositories."))
      end
    end

    def ensure_has_url_for_ostree
      return true if url.present? || library_instance_id
      errors.add(:url, N_("cannot be blank. RPM OSTree Repository URL required for syncing from the upstream."))
    end

    def ensure_ostree_repo_protected
      if unprotected
        errors.add(:base, N_("OSTree Repositories cannot be unprotected."))
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

    def update_ostree_upstream_sync_policy
      return unless ostree?
      if self.ostree_upstream_sync_policy.blank?
        self.ostree_upstream_sync_policy = OSTREE_UPSTREAM_SYNC_POLICY_LATEST
      end

      if self.ostree_upstream_sync_policy_changed? &&
        previous_changes[:ostree_upstream_sync_policy].present?
        self.ostree_upstream_sync_depth = nil unless self.ostree_upstream_sync_policy == OSTREE_UPSTREAM_SYNC_POLICY_CUSTOM
      end
    end

    def ensure_no_ostree_upstream_sync_policy
      if !ostree? && ostree_upstream_sync_policy.present?
        errors.add(:ostree_upstream_sync_policy, N_("cannot be set for non-ostree repositories."))
      end
    end

    def ensure_valid_ignorable_content
      return if ignorable_content.blank?
      if !yum?
        errors.add(:ignorable_content, N_("Ignorable content can be only set for Yum repositories."))
      elsif !ignorable_content.is_a?(Array)
        errors.add(:ignorable_content, N_("Invalid value specified for ignorable content."))
      elsif ignorable_content.any? { |item| !IGNORABLE_CONTENT_UNIT_TYPES.include?(item) }
        errors.add(:ignorable_content, N_("Invalid value specified for ignorable content. Permissible values %s") % IGNORABLE_CONTENT_UNIT_TYPES.join(","))
      end
    end

    def ensure_valid_upstream_authorization
      return if (self.upstream_username.blank? && self.upstream_password.blank?)
      if redhat?
        errors.add(:base, N_("Upstream username and password may only be set on custom repositories."))
      elsif self.upstream_username.blank?
        errors.add(:base, N_("Upstream password requires upstream username be set."))
      elsif !self.upstream_password
        errors.add(:base, N_("Upstream username requires upstream password be set.")) # requirement of pulp
      end
    end

    class Jail < ::Safemode::Jail
      allow :name, :label, :docker_upstream_name, :url
    end
  end
end
