module Katello
  # rubocop:disable Metrics/ClassLength
  class Repository < Katello::Model
    self.include_root_in_json = false

    validates_lengths_from_database :except => [:label]
    before_destroy :assert_deletable
    before_create :downcase_pulp_id

    include ForemanTasks::Concerns::ActionSubject
    include Glue::Candlepin::Content if (SETTINGS[:katello][:use_cp] && SETTINGS[:katello][:use_pulp])
    include Glue::Pulp::Repo if SETTINGS[:katello][:use_pulp]

    include Glue if (SETTINGS[:katello][:use_cp] || SETTINGS[:katello][:use_pulp])
    include Authorization::Repository

    include Ext::LabelFromName
    include Katello::Engine.routes.url_helpers

    YUM_TYPE = 'yum'.freeze
    FILE_TYPE = 'file'.freeze
    PUPPET_TYPE = 'puppet'.freeze
    DOCKER_TYPE = 'docker'.freeze
    OSTREE_TYPE = 'ostree'.freeze

    CHECKSUM_TYPES = %w(sha1 sha256).freeze

    belongs_to :environment, :inverse_of => :repositories, :class_name => "Katello::KTEnvironment"
    belongs_to :product, :inverse_of => :repositories
    belongs_to :gpg_key, :inverse_of => :repositories
    belongs_to :library_instance, :class_name => "Katello::Repository", :inverse_of => :library_instances_inverse
    has_many :library_instances_inverse, # TODO: what is the proper name?
             :class_name  => 'Katello::Repository',
             :dependent   => :restrict_with_exception,
             :foreign_key => :library_instance_id
    has_many :content_view_repositories, :class_name => "Katello::ContentViewRepository",
                                         :dependent => :destroy, :inverse_of => :repository
    has_many :content_views, :through => :content_view_repositories

    has_many :repository_errata, :class_name => "Katello::RepositoryErratum", :dependent => :destroy
    has_many :errata, :through => :repository_errata

    has_many :repository_rpms, :class_name => "Katello::RepositoryRpm", :dependent => :destroy
    has_many :rpms, :through => :repository_rpms

    has_many :repository_puppet_modules, :class_name => "Katello::RepositoryPuppetModule", :dependent => :destroy
    has_many :puppet_modules, :through => :repository_puppet_modules

    has_many :repository_docker_manifests, :class_name => "Katello::RepositoryDockerManifest", :dependent => :destroy
    has_many :docker_manifests, :through => :repository_docker_manifests

    has_many :docker_tags, :dependent => :destroy, :class_name => "Katello::DockerTag"

    has_many :repository_ostree_branches, :class_name => "Katello::RepositoryOstreeBranch", :dependent => :destroy
    has_many :ostree_branches, :through => :repository_ostree_branches

    has_many :system_repositories, :class_name => "Katello::SystemRepository", :dependent => :destroy
    has_many :systems, :through => :system_repositories

    has_many :content_facet_repositories, :class_name => "Katello::ContentFacetRepository", :dependent => :destroy
    has_many :content_facets, :through => :content_facet_repositories

    has_many :repository_package_groups, :class_name => "Katello::RepositoryPackageGroup", :dependent => :destroy
    has_many :package_groups, :through => :repository_package_groups

    has_many :kickstart_content_facets, :class_name => "Katello::Host::ContentFacet", :foreign_key => :kickstart_repository_id,
                          :inverse_of => :kickstart_repository, :dependent => :nullify

    # rubocop:disable HasAndBelongsToMany
    # TODO: change this into has_many :through association
    has_and_belongs_to_many :filters, :class_name => "Katello::ContentViewFilter",
                                      :join_table => :katello_content_view_filters_repositories,
                                      :foreign_key => :content_view_filter_id
    belongs_to :content_view_version, :inverse_of => :repositories, :class_name => "Katello::ContentViewVersion"

    validates :product_id, :presence => true
    validates :pulp_id, :presence => true, :uniqueness => true, :if => proc { |r| r.name.present? }
    validates :checksum_type, :inclusion => {:in => CHECKSUM_TYPES, :allow_blank => true}
    validates :docker_upstream_name, :allow_blank => true, :if => :docker?, :format => {
      :with => /\A([a-z0-9\-_]{4,30}\/)?[a-z0-9\-_\.]{3,30}\z/,
      :message => _("must be a valid docker name")
    }

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
    validate :ensure_valid_docker_attributes, :if => :docker?
    validate :ensure_docker_repo_unprotected, :if => :docker?
    validate :ensure_has_url_for_ostree, :if => :ostree?
    validate :ensure_ostree_repo_protected, :if => :ostree?

    scope :has_url, -> { where('url IS NOT NULL') }
    scope :in_default_view, -> { joins(:content_view_version => :content_view).where("#{Katello::ContentView.table_name}.default" => true) }

    scope :yum_type, -> { where(:content_type => YUM_TYPE) }
    scope :file_type, -> { where(:content_type => FILE_TYPE) }
    scope :puppet_type, -> { where(:content_type => PUPPET_TYPE) }
    scope :docker_type, -> { where(:content_type => DOCKER_TYPE) }
    scope :ostree_type, -> { where(:content_type => OSTREE_TYPE) }
    scope :non_puppet, -> { where("content_type != ?", PUPPET_TYPE) }
    scope :non_archived, -> { where('environment_id is not NULL') }
    scope :archived, -> { where('environment_id is NULL') }

    scoped_search :on => :name, :complete_value => true
    scoped_search :rename => :product, :on => :name, :in => :product, :complete_value => true
    scoped_search :on => :content_type, :complete_value => -> do
      Katello::RepositoryTypeManager.repository_types.keys.each_with_object({}) { |value, hash| hash[value.to_sym] = value }
    end
    scoped_search :on => :content_view_id, :in => :content_view_repositories
    scoped_search :on => :distribution_version, :complete_value => true
    scoped_search :on => :distribution_arch, :complete_value => true
    scoped_search :on => :distribution_family, :complete_value => true
    scoped_search :on => :distribution_variant, :complete_value => true
    scoped_search :on => :distribution_bootable, :complete_value => true
    scoped_search :on => :distribution_uuid, :complete_value => true

    def organization
      if self.environment
        self.environment.organization
      else
        self.content_view.organization
      end
    end

    def content_view
      self.content_view_version.content_view
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

    def archive?
      self.environment.nil?
    end

    def in_default_view?
      content_view_version && content_view_version.default_content_view?
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
      clones << library_repo
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

    def self.repo_id(product_label, repo_label, env_label, organization_label,
                     view_label, version, docker_repo_name = nil)
      actual_repo_id = [organization_label,
                        env_label,
                        view_label,
                        version,
                        product_label,
                        repo_label,
                        docker_repo_name].compact.join("-").gsub(/[^-\w]/, "_")
      # docker repo names need to be in lower case
      actual_repo_id = actual_repo_id.downcase if docker_repo_name
      actual_repo_id
    end

    def clone_id(env, content_view, version = nil)
      Repository.repo_id(self.product.label, self.label, env.try(:label),
                         organization.label, content_view.label,
                         version)
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

    def container_repository_name
      pulp_id if docker?
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
        fail _("Cannot clone repository from %{from_env} to %{to_env}. They are not sequential.") %
                  {:from_env => self.environment.name, :to_env => to_env.name} if to_env.prior != self.environment
        fail _("Repository has already been promoted to %{to_env}") %
                {:to_env => to_env} if self.cloned_in?(to_env)
      else
        fail _("Repository has already been cloned to %{cv_name} in environment %{to_env}") %
                  {:to_env => to_env, :cv_name => content_view.name} if to_env &&
            content_view.repos(to_env).where(:library_instance_id => library.id).count > 0
      end

      Repository.new(:environment => to_env,
                     :product => self.product,
                     :cp_label => self.cp_label,
                     :library_instance => library,
                     :label => self.label,
                     :name => self.name,
                     :arch => self.arch,
                     :major => self.major,
                     :minor => self.minor,
                     :content_id => self.content_id,
                     :content_view_version => to_version,
                     :content_type => self.content_type,
                     :download_policy => download_policy,
                     :unprotected => self.unprotected) do |clone|
        clone.checksum_type = self.checksum_type
        clone.pulp_id = clone.clone_id(to_env, content_view, version.try(:version))
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
      @latest_dynflow_sync ||= ForemanTasks::Task::DynflowTask.for_action(::Actions::Katello::Repository::Sync).
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
      if environment.present?
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
      elsif docker?
        remove_docker_content(units)
      end
    end

    def assert_deletable
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
    end

    def hosts_with_applicability
      ::Host.joins(:content_facet => :bound_repositories).where("#{Katello::Repository.table_name}.id" => (self.clones.pluck(:id) + [self.id]))
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

    def ensure_valid_docker_attributes
      if library_instance? && (url.blank? || docker_upstream_name.blank?)
        errors.add(:base, N_("Repository URL or Upstream Name is empty. Both are required for syncing from the upstream."))
      end
    end

    def ensure_docker_repo_unprotected
      unless unprotected
        errors.add(:base, N_("Docker Repositories are not protected at this time. " \
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
      self.docker_tags.where(:docker_manifest_id => manifests.map(&:id)).destroy_all
      self.docker_manifests -= manifests
      # destroy any orphan docker manifests
      manifests.each do |manifest|
        manifest.destroy if manifest.repositories.empty?
      end
    end
  end
end
