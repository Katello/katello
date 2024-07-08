module Katello
  class ActivationKey < Katello::Model
    audited :except => [:cp_id], :associations => [:host_collections]
    include Glue::Candlepin::ActivationKey
    include Glue
    include Katello::Authorization::ActivationKey
    include ForemanTasks::Concerns::ActionSubject
    include ScopedSearchExtensions

    belongs_to :organization, :inverse_of => :activation_keys
    belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :activation_keys
    belongs_to :user, :inverse_of => :activation_keys, :class_name => "::User"
    belongs_to :content_view, :class_name => "Katello::ContentView", :inverse_of => :activation_keys

    has_many :key_host_collections, :class_name => "Katello::KeyHostCollection", :dependent => :destroy
    has_many :host_collections, :through => :key_host_collections

    has_many :pool_activation_keys, :class_name => "Katello::PoolActivationKey", :dependent => :destroy, :inverse_of => :activation_key
    has_many :pools, :through => :pool_activation_keys, :class_name => "Katello::Pool"
    has_many :subscriptions, :through => :pools

    has_many :subscription_facet_activation_keys, :class_name => "Katello::SubscriptionFacetActivationKey", :dependent => :destroy
    has_many :subscription_facets, :through => :subscription_facet_activation_keys

    has_many :activation_key_purpose_addons, :class_name => "Katello::ActivationKeyPurposeAddon", :dependent => :destroy, :inverse_of => :activation_key
    has_many :purpose_addons, :class_name => "Katello::PurposeAddon", :through => :activation_key_purpose_addons

    alias_method :lifecycle_environment, :environment

    before_validation :set_default_content_view, :unless => :persisted?
    before_destroy :validate_destroyable!
    accepts_nested_attributes_for :purpose_addons

    validates_lengths_from_database
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates :name, :presence => true
    validates :name, :format => { without: /,/, message: _('cannot contain commas') }
    validates :name, :uniqueness => {:scope => :organization_id}
    validate :environment_exists
    validates :max_hosts, :numericality => {:less_than => 2**31, :allow_nil => true}
    validates_each :max_hosts do |record, attr, value|
      if record.unlimited_hosts
        unless value.nil?
          record.errors[attr] << _("cannot be set because unlimited hosts is set")
        end
      else
        if value.nil?
          record.errors[attr] << _("cannot be nil")
        elsif value <= 0
          record.errors[attr] << _("cannot be less than one")
        elsif value < record.subscription_facets.length
          # we don't let users to set usage limit lower than current in-use
          record.errors[attr] << _("cannot be lower than current usage count (%s)" % record.subscription_facets.length)
        end
      end
    end
    validates_with Validators::ContentViewEnvironmentValidator

    scope :in_environment, ->(env) { where(:environment_id => env) }

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :rename => :environment, :on => :name, :relation => :environment, :complete_value => true
    scoped_search :rename => :content_view, :on => :name, :relation => :content_view, :complete_value => true
    scoped_search :on => :content_view_id, :complete_value => true, :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :description, :complete_value => true
    scoped_search :on => :name, :relation => :subscriptions, :rename => :subscription_name, :complete_value => true, :ext_method => :find_by_subscription_name
    scoped_search :on => :id, :relation => :subscriptions, :rename => :subscription_id, :complete_value => true,
                  :only_explicit => true, :validator => ScopedSearch::Validators::INTEGER, :ext_method => :find_by_subscription_id
    scoped_search :on => :purpose_usage, :rename => :usage, :complete_value => true
    scoped_search :on => :purpose_role, :rename => :role, :complete_value => true
    scoped_search :on => :name, :rename => :addon, :relation => :purpose_addon, :complete_value => true, :ext_method => :find_by_purpose_addons

    def environment_exists
      if environment_id && environment.nil?
        errors.add(:environment, _("ID: %s doesn't exist ") % environment_id)
      elsif !environment.nil? && environment.organization != self.organization
        errors.add(:environment, _("name: %s doesn't exist ") % environment.name)
      end
    end

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
      if self.environment
        self.environment.available_releases
      else
        self.organization.library.available_releases
      end
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
      new_key.attributes = self.attributes.slice("description", "environment_id", "organization_id", "content_view_id", "max_hosts", "unlimited_hosts")
      new_key.host_collection_ids = self.host_collection_ids
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

    private

    def set_default_content_view
      if self.environment && self.content_view.nil?
        self.content_view = self.environment.try(:default_content_view)
      end
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
