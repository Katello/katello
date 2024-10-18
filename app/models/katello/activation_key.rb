module Katello
  class ActivationKey < Katello::Model
    audited :except => [:cp_id], :associations => [:host_collections]
    include Glue::Candlepin::ActivationKey
    include Glue
    include Katello::Authorization::ActivationKey
    include ForemanTasks::Concerns::ActionSubject
    include ScopedSearchExtensions

    has_many :content_view_environment_activation_keys, :class_name => "Katello::ContentViewEnvironmentActivationKey",
             :dependent => :destroy, :inverse_of => :activation_key
    has_many :content_view_environments, :through => :content_view_environment_activation_keys,
             :class_name => "Katello::ContentViewEnvironment", :source => :content_view_environment

    has_many :content_views, :through => :content_view_environments, :class_name => "Katello::ContentView"
    has_many :lifecycle_environments, :through => :content_view_environments, :class_name => "Katello::KTEnvironment"

    belongs_to :organization, :inverse_of => :activation_keys
    belongs_to :user, :inverse_of => :activation_keys, :class_name => "::User"
    has_many :key_host_collections, :class_name => "Katello::KeyHostCollection", :dependent => :destroy
    has_many :host_collections, :through => :key_host_collections

    has_many :pool_activation_keys, :class_name => "Katello::PoolActivationKey", :dependent => :destroy, :inverse_of => :activation_key
    has_many :pools, :through => :pool_activation_keys, :class_name => "Katello::Pool"
    has_many :subscriptions, :through => :pools

    has_many :subscription_facet_activation_keys, :class_name => "Katello::SubscriptionFacetActivationKey", :dependent => :destroy
    has_many :subscription_facets, :through => :subscription_facet_activation_keys

    has_many :activation_key_purpose_addons, :class_name => "Katello::ActivationKeyPurposeAddon", :dependent => :destroy, :inverse_of => :activation_key
    has_many :purpose_addons, :class_name => "Katello::PurposeAddon", :through => :activation_key_purpose_addons

    before_destroy :validate_destroyable!
    accepts_nested_attributes_for :purpose_addons

    validates_lengths_from_database
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates :name, :presence => true
    validates :name, :format => { without: /,/, message: _('cannot contain commas') }
    validates :name, :uniqueness => {:scope => :organization_id}
    validates :max_hosts, :numericality => {:less_than => 2**31, :allow_nil => true}
    validates_each :max_hosts do |record, attr, value|
      if record.unlimited_hosts
        unless value.nil?
          record.errors.add(attr, _("cannot be set because unlimited hosts is set"))
        end
      else
        if value.nil?
          record.errors.add(attr, _("cannot be nil"))
        elsif value <= 0
          record.errors.add(attr, _("cannot be less than one"))
        elsif value < record.subscription_facets.length
          # we don't let users to set usage limit lower than current in-use
          record.errors.add(attr, _("cannot be lower than current usage count (%s)" % record.subscription_facets.length))
        end
      end
    end
    validates_with Katello::Validators::GeneratedContentViewValidator
    validate :check_cves

    scope :with_environments, ->(lifecycle_environments) do
      joins(:content_view_environment_activation_keys => :content_view_environment).
        where("#{::Katello::ContentViewEnvironment.table_name}.environment_id" => lifecycle_environments)
    end

    scope :with_content_views, ->(content_views) do
      joins(:content_view_environment_activation_keys => :content_view_environment).
        where("#{::Katello::ContentViewEnvironment.table_name}.content_view_id" => content_views)
    end

    scope :with_content_view_environments, ->(content_view_environments) do
      joins(:content_view_environment_activation_keys => :content_view_environment).
        where("#{::Katello::ContentViewEnvironment.table_name}.id" => content_view_environments)
    end

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER

    scoped_search :relation => :content_views, :on => :name, :complete_value => true, :rename => :content_view, :only_explicit => true
    scoped_search :relation => :content_views, :on => :id, :complete_value => true, :rename => :content_view_id, :only_explicit => true

    scoped_search :relation => :lifecycle_environments, :on => :id, :complete_value => true, :rename => :lifecycle_environment_id, :only_explicit => true
    scoped_search :relation => :lifecycle_environments, :on => :name, :complete_value => true, :rename => :environment, :only_explicit => true

    scoped_search :on => :description, :complete_value => true
    scoped_search :on => :name, :relation => :subscriptions, :rename => :subscription_name, :complete_value => true, :ext_method => :find_by_subscription_name
    scoped_search :on => :id, :relation => :subscriptions, :rename => :subscription_id, :complete_value => true,
                  :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER, :ext_method => :find_by_subscription_id
    scoped_search :on => :purpose_usage, :rename => :usage, :complete_value => true
    scoped_search :on => :purpose_role, :rename => :role, :complete_value => true
    scoped_search :on => :name, :rename => :addon, :relation => :purpose_addon, :complete_value => true, :ext_method => :find_by_purpose_addons

    def self.in_environments(envs)
      with_environments(envs)
    end

    def content_view_environments=(new_cves)
      if new_cves.length > 1 && !Setting['allow_multiple_content_views']
        fail ::Katello::Errors::MultiEnvironmentNotSupportedError,
        _("Assigning an activation key to multiple content view environments is not enabled.")
      end
      super(new_cves)
      Katello::ContentViewEnvironmentActivationKey.reprioritize_for_activation_key(self, new_cves)
      self.content_view_environments.reload unless self.new_record?
    end

    def multi_content_view_environment?
      # returns false if there are no content view environments
      content_view_environments.size > 1
    end

    def single_content_view_environment?
      # also returns false if there are no content view environments
      content_view_environments.size == 1
    end

    def single_content_view
      if multi_content_view_environment?
        Rails.logger.warn _("Activation key %s has more than one content view. Use #content_views instead.") % name
      end
      content_view_environments&.first&.content_view
    end

    def content_view
      single_content_view
    end

    def environment
      single_lifecycle_environment
    end

    def single_lifecycle_environment
      if multi_content_view_environment?
        Rails.logger.warn _("Activation key %s has more than one lifecycle environment. Use #lifecycle_environments instead.") % name
      end
      content_view_environments&.first&.lifecycle_environment
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity
    def assign_single_environment(
      content_view_id: nil, lifecycle_environment_id: nil, environment_id: nil,
      content_view: nil, lifecycle_environment: nil, environment: nil
    )
      lifecycle_environment_id ||= environment_id || lifecycle_environment&.id || environment&.id || self.single_lifecycle_environment&.id
      content_view_id ||= content_view&.id || self.single_content_view&.id

      unless lifecycle_environment_id
        fail _("Lifecycle environment must be specified")
      end

      unless content_view_id
        fail _("Content view must be specified")
      end

      content_view_environment = ::Katello::ContentViewEnvironment
        .where(:content_view_id => content_view_id, :environment_id => lifecycle_environment_id)
        .first_or_create do |cve|
        Rails.logger.info("ContentViewEnvironment not found for content view '#{cve.content_view_name}' and environment '#{cve.environment&.name}'; creating a new one.")
      end
      fail _("Unable to create ContentViewEnvironment. Check the logs for more information.") if content_view_environment.nil?

      if self.content_view_environments.include?(content_view_environment)
        Rails.logger.info("Activation key '#{name}' already has the content view environment '#{content_view_environment.content_view_name}' and environment '#{content_view_environment.environment&.name}'.")
      else
        self.content_view_environments = [content_view_environment]
      end
    end
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    def usage_count
      subscription_facet_activation_keys.count
    end

    def hosts
      subscription_facets.map(&:host)
    end

    def related_resources
      self.organization
    end

    def available_releases
      releases = self.content_view_environments.flat_map do |cve|
        cve.content_view.version(cve.lifecycle_environment).available_releases
      end
      return self.organization.library.available_releases if releases.blank?
      releases
    end

    def available_subscriptions
      all_pools = self.get_pools.map { |pool| pool["id"] }
      added_pools = self.pools.pluck(:cp_id)
      available_pools = all_pools - added_pools
      Pool.where(:cp_id => available_pools,
                 :subscription_id => Subscription.subscribable)
    end

    def products
      Katello::Product.distinct.joins(:pools => :activation_keys).where("#{Katello::ActivationKey.table_name}.id" => self.id).enabled.sort
    end

    def valid_content_override_label?(content_label)
      self.available_content.map(&:content).any? { |content| content.label == content_label }
    end

    def calculate_consumption(product, pools, _allocate)
      pools = pools.sort_by { |pool| [pool.start_date, pool.cp_id] }
      consumption = {}

      if product.provider.redhat_provider?
        pools.each do |pool|
          consumption[pool] ||= 0
          consumption[pool] += 1
        end
      else
        consumption[pools.first] = 1
      end
      return consumption
    end

    def copy(new_name)
      new_key = ActivationKey.new
      new_key.name = new_name
      new_key.attributes = self.attributes.slice("description", "organization_id", "max_hosts", "unlimited_hosts")
      new_key.host_collection_ids = self.host_collection_ids
      new_key.content_view_environments = content_view_environments
      new_key
    end

    def subscribe_to_pool(pool_id, quantity = 1)
      self.subscribe(pool_id, quantity)
    rescue RestClient::ResourceNotFound, RestClient::BadRequest => e
      raise JSON.parse(e.response)['displayMessage']
    end

    def unsubscribe_from_pool(pool_id)
      self.unsubscribe(pool_id)
    rescue RestClient::ResourceNotFound, RestClient::BadRequest => e
      raise JSON.parse(e.response)['displayMessage']
    end

    def self.humanize_class_name(_name = nil)
      _("Activation Keys")
    end

    def self.find_by_subscription_name(_key, operator, value)
      conditions = sanitize_sql_for_conditions(["#{Katello::Subscription.table_name}.name #{operator} ?", value_to_sql(operator, value)])
      activation_keys = ::Katello::ActivationKey.joins(pools: :subscription).where(conditions)
      return_activation_keys_by_id(activation_keys.pluck(:id))
    end

    def self.find_by_subscription_id(_key, operator, value)
      # What we refer to as "subscriptions" is really Pools, so we search based on Pool id.
      conditions = sanitize_sql_for_conditions(["#{Katello::Pool.table_name}.id #{operator} ?", value_to_sql(operator, value)])
      activation_keys = ::Katello::ActivationKey.joins(:pools).where(conditions)
      return_activation_keys_by_id(activation_keys.pluck(:id))
    end

    def self.return_activation_keys_by_id(activation_key_ids)
      if activation_key_ids.empty?
        {:conditions => "1=0"}
      else
        {:conditions => "#{Katello::ActivationKey.table_name}.id IN (#{activation_key_ids.join(',')})"}
      end
    end

    def self.find_by_purpose_addons(_key, operator, value)
      conditions = sanitize_sql_for_conditions(["#{Katello::PurposeAddon.table_name}.name #{operator} ?", value_to_sql(operator, value)])
      activation_keys = ::Katello::ActivationKey.joins(:purpose_addons).where(conditions)
      return_activation_keys_by_id(activation_keys.pluck(:id))
    end

    def validate_destroyable!
      if !organization.being_deleted? && Parameter.where(name: 'kt_activation_keys').pluck(:value).any? { |value| value.split(",").include?(name) }
        fail _("This activation key is associated to one or more Hosts/Hostgroups. "\
                "Search and unassociate Hosts/Hostgroups using params.kt_activation_keys ~ \"%{name}\" "\
                "before deleting." % {name: name})
      end
      true
    end

    def check_cves
      cves_not_in_org = self.content_view_environments.any? do |cve|
        cve.content_view.organization != cve.environment.organization ||
          self.organization != cve.content_view.organization
      end

      errors.add(:base, _("Cannot add content view environments from a different organization")) if cves_not_in_org
    end

    apipie :class, desc: "A class representing #{model_name.human} object" do
      name 'Activation Key'
      refs 'ActivationKey'
      sections only: %w[all additional]
      property :name, String, desc: 'Returns the name of the Activation Key.'
    end
    class Jail < ::Safemode::Jail
      allow :name
    end
  end
end
