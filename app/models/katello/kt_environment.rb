module Katello
  class KTEnvironment < Katello::Model
    audited :associations => [:content_facets]
    include ForemanTasks::Concerns::ActionSubject
    include Authorization::LifecycleEnvironment

    self.table_name = "katello_environments"
    include Ext::LabelFromName

    belongs_to :organization, :class_name => "Organization", :inverse_of => :kt_environments
    has_many :activation_keys, :class_name => "Katello::ActivationKey",
                               :dependent => :restrict_with_exception, :foreign_key => :environment_id

    has_many :env_priors, :class_name => "Katello::EnvironmentPrior", :foreign_key => :environment_id, :dependent => :destroy
    has_many :priors, :class_name => "Katello::KTEnvironment", :through => :env_priors, :source => :env_prior

    has_many :env_successors, :class_name => "Katello::EnvironmentPrior", :foreign_key => :prior_id, :dependent => :destroy
    has_many :successors, :class_name => "Katello::KTEnvironment", :through => :env_successors, :source => :env

    has_many :repositories, :class_name => "Katello::Repository", dependent: :destroy, foreign_key: :environment_id
    has_many :content_view_environments, :class_name => "Katello::ContentViewEnvironment",
                                         :foreign_key => :environment_id, :inverse_of => :environment, :dependent => :restrict_with_exception
    has_many :content_view_versions, :through => :content_view_environments, :inverse_of => :environments
    has_many :content_views, :through => :content_view_environments, :inverse_of => :environments
    has_many :content_view_histories, :class_name => "Katello::ContentViewHistory", :dependent => :destroy,
                                      :inverse_of => :environment, :foreign_key => :katello_environment_id

    has_many :content_facets, :class_name => "Katello::Host::ContentFacet", :foreign_key => :lifecycle_environment_id,
                          :inverse_of => :lifecycle_environment, :dependent => :restrict_with_exception
    has_many :hosts,      :class_name => "::Host::Managed", :through => :content_facets,
                          :inverse_of => :lifecycle_environment
    has_many :hostgroup_content_facets, :class_name => "Katello::Hostgroup::ContentFacet", :foreign_key => :lifecycle_environment_id,
                          :inverse_of => :lifecycle_environment, :dependent => :restrict_with_exception
    has_many :hostgroups, :class_name => "::Hostgroup", :through => :hostgroup_content_facets,
                          :inverse_of => :lifecycle_environment

    scope :completer_scope, ->(options = nil) { where('organization_id = ?', options[:organization_id]) if options[:organization_id].present? }
    scope :non_library, -> { where(library: false) }
    scope :library, -> { where(library: true) }

    validates_lengths_from_database :except => [:label]
    validates :organization, :presence => true
    validates :name, :presence => true, :uniqueness => {:scope => :organization_id,
                                                        :message => N_("of environment must be unique within one organization")},
                     :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library", :unless => :library? }
    validates :label, :presence => true, :uniqueness => {:scope => :organization_id,
                                                         :message => N_("of environment must be unique within one organization")},
                      :exclusion => { :in => ["Library"], :message => N_(": '%s' is a built-in environment") % "Library", :unless => :library? }
    validates :label, :exclusion => { :in => [ContentView::CONTENT_DIR], :message => N_(": '%s' is a built-in environment") % ContentView::CONTENT_DIR }

    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
    validates_with Validators::PriorValidator
    validates_with Validators::PathDescendentsValidator

    validates_with Katello::Validators::EnvironmentDockerRepositoriesValidator

    has_many :capsule_lifecycle_environments, :foreign_key => :lifecycle_environment_id,
                                              :dependent => :destroy, :inverse_of => :lifecycle_environment

    # RAILS3458: before_destroys before associations. see http://tinyurl.com/rails3458
    before_destroy :assert_deletable, :prepend => true
    before_destroy :remove_from_path, :prepend => true

    scope(:not_in_capsule,
      lambda do |capsule|
        select("DISTINCT #{KTEnvironment.table_name}.*").
          joins(%{LEFT OUTER JOIN #{CapsuleLifecycleEnvironment.table_name} ON ( "#{CapsuleLifecycleEnvironment.table_name}"."lifecycle_environment_id" = "#{KTEnvironment.table_name}"."id")}).
          where(%("#{CapsuleLifecycleEnvironment.table_name}"."capsule_id" IS NULL
          OR "#{CapsuleLifecycleEnvironment.table_name}"."capsule_id" != ?), capsule.id)
      end)

    after_create :add_to_default_capsule

    ERROR_CLASS_NAME = "Environment".freeze

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :label, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

    def library?
      self.library
    end

    def default_content_view
      self.default_content_view_version.try(:content_view)
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

    # creates new env from create_params with self as a prior
    def insert_successor(create_params, path)
      self.class.transaction do
        new_successor = self.class.create!(create_params)
        if library?
          if path
            old_successor = path.first
            old_successor.prior = new_successor
          end
          save_successor new_successor
        elsif successor.nil?
          save_successor new_successor
        else
          old_successor = successor
          old_successor.prior = new_successor
          save_successor new_successor
        end
        fail HttpErrors::UnprocessableEntity, _('An environment is missing a prior') unless all_have_prior?
        new_successor
      end
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

    def prior=(env)
      env_id = env.is_a?(ActiveRecord::Base) ? env.id : env
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

    def assert_deletable
      throw :abort unless deletable?
    end

    def deletable?
      return true if self.organization.nil? || self.organization.being_deleted?

      if library?
        errors.add :base, _("Library lifecycle environments may not be deleted.")
      end

      if content_facets.any?
        errors.add(:base,
           _("Lifecycle Environment %s has associated Hosts." \
              " Please unregister or move the associated Hosts before trying to delete this lifecycle environment.") % self.name)
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

    def as_json(_options = {})
      to_ret = self.attributes
      to_ret['prior'] = self.prior && self.prior.name
      to_ret['prior_id'] = self.prior && self.prior.id
      to_ret['organization'] = self.organization && self.organization.name
      to_ret
    end

    def remove_from_path
      if self.successor && self.prior
        prior_env = self.prior
        self.env_priors.destroy_all
        self.successor.env_priors.first.update!(:prior_id => prior_env.id)
      end
    end

    def key_for(item)
      "environment_#{id}_#{item}"
    end

    def add_to_default_capsule
      SmartProxy.pulp_primary.try(:add_lifecycle_environment, self)
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

    def self.permission_name
      'lifecycle_environments'
    end

    apipie :class, desc: "A class representing #{model_name.human} object" do
      name 'Katello Environment'
      refs 'KTEnvironment'
      sections only: %w[all additional]
      prop_group :katello_basic_props, Katello::Model, meta: { friendly_name: 'Katello Environment' }
    end
    class Jail < ::Safemode::Jail
      allow :name, :label
    end

    private

    def all_have_prior?
      organization.kt_environments.reject { |env| env.library? || env.prior.present? }.empty?
    end

    def save_successor(new_successor)
      new_successor.prior = self
      new_successor.save
    end
  end
end
