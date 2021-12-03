module Katello
  class Product < Katello::Model
    audited

    include ForemanTasks::Concerns::ActionSubject
    include Glue::Candlepin::Product
    include Glue::Pulp::Repos
    include Glue

    include Katello::Authorization::Product

    include Ext::LabelFromName

    belongs_to :organization, :inverse_of => :products
    belongs_to :provider, :inverse_of => :products, :class_name => 'Katello::Provider'
    belongs_to :sync_plan, :inverse_of => :products, :class_name => 'Katello::SyncPlan'
    belongs_to :gpg_key, :inverse_of => :products, :class_name => "Katello::ContentCredential"
    has_many :product_contents, :class_name => "Katello::ProductContent", :dependent => :destroy
    has_many :contents, :through => :product_contents
    has_many :displayable_product_contents, -> { displayable }, :foreign_key => 'product_id', :class_name => "Katello::ProductContent", :dependent => :destroy
    belongs_to :ssl_ca_cert, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_ca_products
    belongs_to :ssl_client_cert, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_client_products
    belongs_to :ssl_client_key, :class_name => "Katello::ContentCredential", :inverse_of => :ssl_key_products
    has_many :root_repositories, :class_name => "Katello::RootRepository", :dependent => :restrict_with_exception
    has_many :repositories, :through => :root_repositories

    has_many :pool_products, :class_name => "Katello::PoolProduct", :dependent => :destroy
    has_many :pools, :through => :pool_products
    has_many :subscriptions, :through => :pools, :dependent => :destroy

    validates_lengths_from_database :except => [:label]
    validates :provider_id, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
    validates_with Validators::ProductUniqueAttributeValidator, :attributes => :name
    validates_with Validators::ProductUniqueAttributeValidator, :attributes => :label
    validates_with Validators::GpgKeyContentTypeValidator

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :label, :complete_value => true
    scoped_search :on => :description
    scoped_search :relation => :provider, :on => :provider_type, :rename => :redhat,
                  :complete_value => {:true => Katello::Provider::REDHAT, :false => Katello::Provider::ANONYMOUS }

    def library_repositories
      self.repositories.in_default_view
    end

    def self.find_by_cp_id(cp_id, organization = nil)
      query = self.where(:cp_id => cp_id).readonly(false)
      query = query.in_org(organization) if organization
      query.first
    end

    def self.in_org(organization)
      where(:organization_id => organization.id)
    end

    def self.in_orgs(organizations)
      where(:organization_id => organizations)
    end

    scope :syncable_content, -> { distinct.where(Katello::RootRepository.arel_table[:url].not_eq(nil)).joins(:root_repositories) }
    scope :redhat, -> { joins(:provider).where("#{Provider.table_name}.provider_type" => Provider::REDHAT) }
    scope :custom, -> { joins(:provider).where("#{Provider.table_name}.provider_type" => [Provider::CUSTOM, Provider::ANONYMOUS]) }
    scope :with_contents, -> { includes(:product_contents) }

    def self.subscribable
      joins("LEFT OUTER JOIN #{Katello::RootRepository.table_name} repo ON repo.product_id = #{self.table_name}.id")
        .where("repo.content_type IN (?) OR repo IS NULL", RootRepository::SUBSCRIBABLE_TYPES)
        .group("#{self.table_name}.id, repo.product_id")
    end

    def self.enabled
      self.where("#{Product.table_name}.id in (?) or #{Product.table_name}.id in (?)",
                 Product.redhat.joins(:root_repositories => :repositories).select(:id), Product.custom.select(:id))
    end

    before_create :assign_unique_label

    def orphaned?
      self.pool_products.empty?
    end

    def repos(env, content_view = nil, include_feedless = true)
      if content_view.nil?
        if !env.library?
          fail "No content view specified for the repos call in a " \
                          "Non library environment #{env.inspect}"
        else
          content_view = env.default_content_view
        end
      end

      # cache repos so we can cache lazy_accessors
      @repo_cache ||= {}
      @repo_cache[env.id] ||= content_view.repos_in_product(env, self)

      repositories = @repo_cache[env.id]
      repositories = repositories.has_url unless include_feedless
      repositories
    end

    def enabled?
      !self.provider.redhat_provider? || self.repositories.present?
    end

    delegate :cdn_configuration, :library, to: :organization

    def plan_name
      return sync_plan.name if sync_plan
      N_('None')
    end

    def serializable_hash(options = {})
      options = {} if options.nil?

      hash = super(options.merge(:except => [:cp_id, :id]))
      hash = hash.merge(:multiplier => self.multiplier,
                        :attributes => self.attrs,
                        :id => self.cp_id,
                        :sync_plan_name => self.sync_plan ? self.sync_plan.name : nil,
                        :sync_state => self.sync_state,
                        :last_sync => self.last_sync)
      hash
    end

    def redhat?
      provider.redhat_provider?
    end

    def user_deletable?
      self.published_content_views.empty? && !self.redhat?
    end

    def custom?
      !redhat?
    end

    def published_content_views
      Katello::ContentView.non_default.joins(:content_view_versions => {:repositories => :root}).
          where("#{Katello::RootRepository.table_name}.product_id" => self.id)
    end

    def published_content_view_versions
      Katello::ContentViewVersion.joins(:content_view).joins(:repositories => :root).
          where("#{Katello::ContentView.table_name}.default" => false).
          where("#{Katello::RootRepository.table_name}.product_id" => self.id).order(:content_view_id)
    end

    def anonymous?
      provider.anonymous_provider?
    end

    def used_by_another_org?
      self.class.where(["cp_id = ? AND id != ?", cp_id, id]).count > 0
    end

    scope :all_in_org, ->(org) { joins(:provider).where("#{Katello::Provider.table_name}.organization_id = ?", org.id) }

    def assign_unique_label
      self.label = Util::Model.labelize(self.name) if self.label.blank?

      # if the object label is already being used in this org, append the id to make it unique
      if Product.all_in_org(self.organization).where("#{Katello::Product.table_name}.label = ?", self.label).count > 0
        self.label = self.label + "_" + self.cp_id unless self.cp_id.blank?
      end
    end

    def delete_repos(repos)
      repos.each { |repo| repo.destroy }
    end

    def delete_from_env(from_env)
      @orchestration_for = :delete
      delete_repos(repos(from_env))
      if from_env.products.include? self
        self.environments.delete(from_env)
      end
      save!
    end

    def environments_for_view(view)
      versions = view.versions.select { |version| version.products.include?(self) }
      versions.collect { |v| v.environments }.flatten
    end

    def environments
      KTEnvironment.where(:organization_id => organization.id).
        where("library = ? OR id IN (?)", true, repositories.map(&:environment_id))
    end

    def syncable_content?
      repositories.any?(&:url?)
    end

    def product_content_by_id(content_id)
      product_contents.joins(:content).where("#{Katello::Content.table_name}.cp_content_id = ?", content_id).first
    end

    def available_content(content_view_version_id = nil)
      root_repos = self.root_repositories.subscribable
      root_repos = root_repos.join(:repositories).where(:content_view_version_id => content_view_version_id) if content_view_version_id
      self.product_contents.joins(:content).where("#{Katello::Content.table_name}.cp_content_id" => root_repos.select(:content_id))
    end

    def related_resources
      self.provider
    end

    def to_action_input
      super.merge(cp_id: cp_id)
    end

    def cdn_resource
      return if self.certificate.nil?

      @cdn_resource ||= ::Katello::Resources::CDN::CdnResource.create(
        product: self,
        cdn_configuration: self.organization.cdn_configuration
      )
    end

    def total_package_count(env, view)
      repo_ids = view.repos(env).in_product(self).collect { |r| r.pulp_id }
      result = Katello::Package.legacy_search('*', 0, 1, repo_ids)
      result.length > 0 ? result.total : 0
    end

    def self.humanize_class_name(_name = nil)
      _("Product and Repositories")
    end

    def self.unused_product_id
      id = SecureRandom.random_number(999_999_999_999)
      if ::Katello::Product.find_by(:cp_id => id)
        unused_product_id
      else
        id
      end
    end

    apipie :class, desc: "A class representing #{model_name.human} object" do
      name 'Product'
      refs 'Product'
      sections only: %w[all additional]
      prop_group :katello_basic_props, Katello::Model, meta: { friendly_name: 'Product' }
    end
    class Jail < ::Safemode::Jail
      allow :name, :label
    end
  end
end
