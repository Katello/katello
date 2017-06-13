module Katello
  class ActivationKey < Katello::Model
    self.include_root_in_json = false

    include Glue::Candlepin::ActivationKey if SETTINGS[:katello][:use_cp]
    include Glue if SETTINGS[:katello][:use_cp]
    include Katello::Authorization::ActivationKey
    include ForemanTasks::Concerns::ActionSubject

    belongs_to :organization, :inverse_of => :activation_keys
    belongs_to :environment, :class_name => "KTEnvironment", :inverse_of => :activation_keys
    belongs_to :user, :inverse_of => :activation_keys, :class_name => "::User"
    belongs_to :content_view, :inverse_of => :activation_keys

    has_many :key_host_collections, :class_name => "Katello::KeyHostCollection", :dependent => :destroy
    has_many :host_collections, :through => :key_host_collections

    has_many :pools, :through => :pool_activation_keys, :class_name => "Katello::Pool"
    has_many :pool_activation_keys, :class_name => "Katello::PoolActivationKey", :dependent => :destroy, :inverse_of => :activation_key
    has_many :subscription_facet_activation_keys, :class_name => "Katello::SubscriptionFacetActivationKey", :dependent => :destroy
    has_many :subscription_facets, :through => :subscription_facet_activation_keys

    before_validation :set_default_content_view, :unless => :persisted?

    validates_lengths_from_database
    validates_with Validators::KatelloNameFormatValidator, :attributes => :name
    validates :name, :presence => true
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

    def subscriptions
      self.pools
    end

    def available_subscriptions
      all_pools = self.get_pools.map { |pool| pool["id"] }
      added_pools = self.pools.pluck(:cp_id)
      available_pools = all_pools - added_pools
      Pool.where(:cp_id => available_pools,
                 :subscription_id => Subscription.with_subscribable_content)
    end

    def products
      all_products = []

      self.pools.each do |pool|
        if pool.subscription
          all_products << pool.subscription.products
        else
          Rails.logger.error("Pool #{pool.id} is missing its subscription id.")
        end
      end
      all_products.uniq.flatten
    end

    def all_products
      Katello::Product.joins(:subscriptions => :pools).where(:organization_id => organization.id).enabled.uniq
    end

    def available_content(content_access_mode_all = false, content_access_mode_env = false)
      if content_access_mode_env
        return [] unless environment_id && content_view_id
        version = ContentViewVersion.in_environment(environment_id).where(:content_view_id => content_view_id).first
        content_view_version_id = version.id
      end

      if content_access_mode_all
        content = all_products.flat_map do |product|
          product.available_content(content_view_version_id)
        end
      else
        content = products.flat_map do |product|
          product.available_content(content_view_version_id)
        end
      end
      content.uniq
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

    private

    def set_default_content_view
      if self.environment && self.content_view.nil?
        self.content_view = self.environment.try(:default_content_view)
      end
    end
  end
end
