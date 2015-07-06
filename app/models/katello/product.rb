module Katello
  class Product < Katello::Model
    self.include_root_in_json = false

    include ForemanTasks::Concerns::ActionSubject
    include Glue::Candlepin::Product if Katello.config.use_cp
    include Glue::Pulp::Repos if Katello.config.use_pulp
    include Glue if Katello.config.use_cp || Katello.config.use_pulp

    include Katello::Authorization::Product

    include Ext::LabelFromName

    has_many :marketing_engineering_products, :class_name => "Katello::MarketingEngineeringProduct",
                                              :foreign_key => :engineering_product_id, :dependent => :destroy
    has_many :marketing_products, :through => :marketing_engineering_products

    belongs_to :organization, :inverse_of => :products
    belongs_to :provider, :inverse_of => :products
    belongs_to :sync_plan, :inverse_of => :products, :class_name => 'Katello::SyncPlan'
    belongs_to :gpg_key, :inverse_of => :products
    has_many :repositories, :class_name => "Katello::Repository", :dependent => :restrict_with_error

    validates_lengths_from_database :except => [:label]
    validates :provider_id, :presence => true
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates_with Validators::KatelloLabelFormatValidator, :attributes => :label
    validates_with Validators::ProductUniqueAttributeValidator, :attributes => :name
    validates_with Validators::ProductUniqueAttributeValidator, :attributes => :label

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true
    scoped_search :on => :label, :complete_value => true
    scoped_search :on => :description
    scoped_search :in => :provider, :on => :provider_type, :rename => :redhat,
                  :complete_value => {:true => Provider::REDHAT, :false => Provider::ANONYMOUS }

    def library_repositories
      self.repositories.in_default_view
    end

    def self.find_by_cp_id(cp_id, organization = nil)
      query = self.where(:cp_id => cp_id).scoped(:readonly => false)
      query = query.in_org(organization) if organization
      query.engineering.first || query.marketing.first
    end

    def self.in_org(organization)
      where(:organization_id => organization.id)
    end

    scope :engineering, where(:type => "Katello::Product")
    scope :marketing, where(:type => "Katello::MarketingProduct")
    scope :syncable_content, uniq.where(Katello::Repository.arel_table[:url].not_eq(nil))
      .joins(:repositories)
    scope :enabled, joins(:repositories).uniq

    before_create :assign_unique_label

    def initialize(attrs = nil, options = {})
      unless attrs.nil?
        attrs = attrs.with_indifferent_access

        #rename "id" to "cp_id" (activerecord and candlepin variable name conflict)
        if attrs.key?(:id)
          unless attrs.key?(:cp_id)
            attrs[:cp_id] = attrs[:id]
          end
          attrs.delete(:id)
        end

        # ugh. hack-ish. otherwise we have to modify code every time things change on cp side
        attrs = attrs.reject do |k, _v|
          !self.class.column_defaults.keys.member?(k.to_s) && (!respond_to?(:"#{k.to_s}=") rescue true)
        end
      end

      super
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

    delegate :organization, to: :provider

    delegate :library, to: :organization

    def plan_name
      return sync_plan.name if sync_plan
      N_('None')
    end

    # rubocop:disable SymbolName
    def serializable_hash(options = {})
      options = {} if options.nil?

      hash = super(options.merge(:except => [:cp_id, :id]))
      hash = hash.merge(:productContent => self.productContent,
                        :multiplier => self.multiplier,
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
      provider.custom_provider?
    end

    def published_content_views
      Katello::ContentView.non_default.joins(:content_view_versions => :repositories).
          where("#{Katello::Repository.table_name}.product_id" => self.id)
    end

    def anonymous?
      provider.anonymous_provider?
    end

    def used_by_another_org?
      self.class.where(["cp_id = ? AND id != ?", cp_id, id]).count > 0
    end

    def gpg_key_name=(name)
      if name.blank?
        self.gpg_key = nil
      else
        self.gpg_key = GpgKey.readable.find_by_name!(name)
      end
    end

    scope :all_in_org, lambda { |org| Product.joins(:provider).where("#{Katello::Provider.table_name}.organization_id = ?", org.id) }

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
      versions.collect { |v|v.environments }.flatten
    end

    def environments
      KTEnvironment.where(:organization_id => organization.id).
        where("library = ? OR id IN (?)", true, repositories.map(&:environment_id))
    end

    def syncable_content?
      repositories.any?(&:url?)
    end

    def available_content
      self.productContent.find_all { |content| self.repositories.where(:content_id => content.content.id).any? }
    end

    def related_resources
      self.provider
    end

    def to_action_input
      super.merge(cp_id: cp_id)
    end

    def cdn_resource
      return unless (product_certificate = certificate)
      certs = { :ssl_client_cert => OpenSSL::X509::Certificate.new(product_certificate),
                :ssl_client_key => OpenSSL::PKey::RSA.new(key) }
      ::Katello::Resources::CDN::CdnResource.new(provider.repository_url, certs)
    end

    def total_package_count(env, view)
      repo_ids = view.repos(env).in_product(self).collect { |r| r.pulp_id }
      result = Katello::Package.legacy_search('*', 0, 1, repo_ids)
      result.length > 0 ? result.total : 0
    end

    def total_puppet_module_count(env, view)
      repo_ids = view.repos(env).in_product(self).collect { |r| r.pulp_id }
      results = Katello::PuppetModule.legacy_search('', :page_size => 1, :repoids => repo_ids)
      results.empty? ? 0 : results.total
    end

    def self.humanize_class_name(_name = nil)
      _("Product and Repositories")
    end
  end
end
