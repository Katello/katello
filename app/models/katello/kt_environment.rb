module Katello
  class KTEnvironment < Katello::Model
    self.include_root_in_json = false

    include ForemanTasks::Concerns::ActionSubject
    include Authorization::LifecycleEnvironment

    self.table_name = "katello_environments"
    include Ext::LabelFromName

    belongs_to :organization, :class_name => "Organization", :inverse_of => :environments
    has_many :activation_keys, :class_name => "Katello::ActivationKey",
                               :dependent => :restrict_with_error, :foreign_key => :environment_id
    # rubocop:disable HasAndBelongsToMany
    # TODO: change these into has_many associations
    has_and_belongs_to_many :priors,  :class_name => "Katello::KTEnvironment", :foreign_key => :environment_id,
                                      :join_table => "katello_environment_priors",
                                      :association_foreign_key => "prior_id", :uniq => true
    has_and_belongs_to_many :successors,  :class_name => "Katello::KTEnvironment", :foreign_key => "prior_id",
                                          :join_table => "katello_environment_priors",
                                          :association_foreign_key => :environment_id, :readonly => true

    has_many :repositories, :class_name => "Katello::Repository", dependent: :destroy, foreign_key: :environment_id
    has_many :systems, :class_name => "Katello::System", :inverse_of => :environment,
                       :dependent => :restrict_with_error, :foreign_key => :environment_id
    has_many :distributors, :class_name => "Katello::Distributor", :inverse_of => :environment,
                            :dependent => :destroy, :foreign_key => :environment_id
    has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment",
                                         :foreign_key => :environment_id, :inverse_of => :environment, :dependent => :restrict_with_error
    has_many :content_view_puppet_environments, :class_name => "Katello::ContentViewPuppetEnvironment",
                                                :foreign_key => :environment_id, :inverse_of => :environment, :dependent => :restrict_with_error
    has_many :content_view_versions, :through => :content_view_environments, :inverse_of => :environments
    has_many :content_views, :through => :content_view_environments, :inverse_of => :environments
    has_many :content_view_histories, :class_name => "Katello::ContentViewHistory", :dependent => :destroy,
                                      :inverse_of => :environment, :foreign_key => :katello_environment_id

    has_many :hosts,      :class_name => "::Host::Managed", :foreign_key => :lifecycle_environment_id,
                              :inverse_of => :lifecycle_environment, :dependent => :restrict_with_error
    has_many :hostgroups, :class_name => "::Hostgroup",     :foreign_key => :lifecycle_environment_id,
                          :inverse_of => :lifecycle_environment, :dependent => :restrict_with_error

    scope :completer_scope, lambda { |options = nil| where('organization_id = ?', options[:organization_id]) if options[:organization_id].present? }
    scope :non_library, where(library: false)
    scope :library, where(library: true)

    validates_lengths_from_database :except => [:label]
    validates :organization, :presence => true
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id,
                                                        :message => N_("of environment must be unique within one organization")},
                     :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library", :unless => :library? }
    validates :label, :presence => true, :uniqueness => {:scope => :organization_id,
                                                         :message => N_("of environment must be unique within one organization")},
                      :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library", :unless => :library?},
                      :exclusion => { :in => [ContentView::CONTENT_DIR], :message => N_(": '%s' is a built-in environment") % ContentView::CONTENT_DIR }
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
    validates_with Validators::PriorValidator
    validates_with Validators::PathDescendentsValidator

    has_many :capsule_lifecycle_environments, :foreign_key => :lifecycle_environment_id,
                                              :dependent => :destroy, :inverse_of => :lifecycle_environment

    # RAILS3458: before_destroys before associations. see http://tinyurl.com/rails3458
    before_destroy :deletable?, :prepend => true

    scope(:not_in_capsule,
          lambda do |capsule|
            select("DISTINCT #{KTEnvironment.table_name}.*").
                joins(%{LEFT OUTER JOIN #{CapsuleLifecycleEnvironment.table_name} ON ( "#{CapsuleLifecycleEnvironment.table_name}"."lifecycle_environment_id" = "#{KTEnvironment.table_name}"."id")}).
                where(%("#{CapsuleLifecycleEnvironment.table_name}"."capsule_id" IS NULL
                       OR "#{CapsuleLifecycleEnvironment.table_name}"."capsule_id" != ?), capsule.id)
          end)

    after_create :add_to_default_capsule

    ERROR_CLASS_NAME = "Environment"

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true

    def library?
      self.library
    end

    def default_content_view
      self.default_content_view_version.try(:content_view, nil)
    end

    def default_content_view_version
      return nil unless self.organization.default_content_view
      self.organization.default_content_view.version(self)
    end

    def content_view_environment
      return nil unless self.default_content_view
      self.default_content_view.content_view_environments.where(:environment_id => self.id).first
    end

    def successor
      return self.successors[0] unless self.library?
      self.organization.promotion_paths[0][0] unless self.organization.promotion_paths.empty?
    end

    def display_name
      self.name
    end

    def to_s
      display_name
    end

    # for multiselect helper in foreman
    def to_label
      return "#{name} (#{organization.title})" if organization && ::Organization.current.nil?
      name
    end

    def prior
      self.priors[0]
    end

    def prior=(env_id)
      self.priors.clear
      return if env_id.nil? || env_id == ""
      prior_env = KTEnvironment.find env_id
      self.priors << prior_env unless prior_env.nil?
    end

    def path
      s = self.successor
      ret = [self]
      until s.nil?
        fail "Environment path has duplicates!!. #{self}. Duplicate => #{ret}. Path => #{s}" if ret.include? s
        ret << s
        s = s.successor
      end
      ret
    end

    #is the environment currently being promoted to
    def promoting_to?
      self.promoting.exists?
    end

    def deletable?
      return true if self.organization.nil? || self.organization.being_deleted?

      if library?
        errors.add :base, _("Library lifecycle environments may not be deleted.")
      elsif !successor.nil?
        errors.add :base, _("Lifecycle Environment %s has a successor.  Only the last lifecycle environment on a path can be deleted") % self.name
      end

      if systems.any?
        errors.add(:base,
           _("Lifecycle Environment %s has associated Content Hosts." \
              " Please unregister or move the associated Content Hosts before trying to delete this lifecycle environment.") % self.name)
      end

      if activation_keys.any?
        errors.add(:base,
           _("Lifecycle Environment %s has associated Activation Keys." \
             " Please change or remove the associated Activation Keys before trying to delete this lifecycle environment.") % self.name)
      end

      return errors.empty?
    end

    #Unlike path which only gives the path from this environment going forward
    #  Get the full path, that is go to the HEAD of the path this environment is on
    #  and then give me that entire path
    def full_path
      p = self
      until p.prior.nil? || p.prior.library
        p = p.prior
      end
      p.prior.nil? ? p.path : [p.prior] + p.path
    end

    def available_products
      if self.prior.library
        # if there is no prior, then the prior is the Library, which has all products
        prior_products = self.organization.library.products
      else
        prior_products = self.prior.products
      end
      return prior_products - self.products
    end

    def products
      self.library? ? Product.in_org(self.organization) : Product.where(id: repositories.map(&:product_id))
    end

    def puppet_repositories
      self.repositories.readable.where(:content_type => Katello::Repository::PUPPET_TYPE)
    end

    def as_json(_options = {})
      to_ret = self.attributes
      to_ret['prior'] = self.prior &&  self.prior.name
      to_ret['prior_id'] = self.prior &&  self.prior.id
      to_ret['organization'] = self.organization &&  self.organization.name
      to_ret
    end

    def key_for(item)
      "environment_#{id}_#{item}"
    end

    def package_groups(search_args = {})
      groups = []
      self.products.each do |prod|
        groups << prod.package_groups(self, search_args)
      end
      groups.flatten(1)
    end

    def package_group_categories(search_args = {})
      categories = []
      self.products.each do |prod|
        categories << prod.package_group_categories(self, search_args)
      end
      categories.flatten(1)
    end

    def find_packages_by_name(name)
      products = self.products.collect do |prod|
        prod.find_packages_by_name(self, name).collect do |p|
          p[:product_id] = prod.cp_id
          p
        end
      end
      products.flatten(1)
    end

    def find_packages_by_nvre(name, version, release, epoch)
      products = self.products.collect do |prod|
        prod.find_packages_by_nvre(self, name, version, release, epoch).collect do |p|
          p[:product_id] = prod.cp_id
          p
        end
      end
      products.flatten(1)
    end

    def find_latest_packages_by_name(name)
      packs = self.products.collect do |prod|
        prod.find_latest_packages_by_name(self, name).collect do |pack|
          pack[:product_id] = prod.cp_id
          pack
        end
      end
      packs.flatten!(1)

      Util::Package.find_latest_packages packs
    end

    def get_distribution(id)
      distribution = self.products.collect do |prod|
        prod.get_distribution(self, id)
      end
      distribution.flatten(1)
    end

    def add_to_default_capsule
      CapsuleContent.default_capsule.try(:add_lifecycle_environment, self)
    end

    # Katello, which understands repository content and promotion, provides release versions based upon
    # enabled repos. Headpin, which does not traverse products to the repo level, exposes all release
    # versions in the manifest.
    def available_releases
      self.repositories.map(&:minor).compact.uniq.sort
    end

    def self.humanize_class_name
      _("Lifecycle Environment")
    end
  end
end
