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

    has_many :system_activation_keys, :class_name => "Katello::SystemActivationKey", :dependent => :destroy
    has_many :systems, :through => :system_activation_keys

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
    validates :max_content_hosts, :numericality => {:less_than => 2**31, :allow_nil => true}
    validates_each :max_content_hosts do |record, attr, value|
      if record.unlimited_content_hosts
        unless value.nil?
          record.errors[attr] << _("cannot be set because unlimited content hosts is set")
        end
      else
        if value.nil?
          record.errors[attr] << _("cannot be nil")
        elsif value <= 0
          record.errors[attr] << _("cannot be less than one")
        elsif value < record.systems.length
          # we don't let users to set usage limit lower than current in-use
          record.errors[attr] << _("cannot be lower than current usage count (%s)" % record.systems.length)
        end
      end
    end
    validates_with Validators::ContentViewEnvironmentValidator

    scope :in_environment, ->(env) { where(:environment_id => env) }

    scoped_search :on => :name, :complete_value => true
    scoped_search :on => :organization_id, :complete_value => true
    scoped_search :rename => :environment, :on => :name, :in => :environment, :complete_value => true
    scoped_search :rename => :content_view, :on => :name, :in => :content_view, :complete_value => true
    scoped_search :on => :content_view_id, :complete_value => true
    scoped_search :on => :description, :complete_value => true

    def environment_exists
      if environment_id && environment.nil?
        errors.add(:environment, _("ID: %s doesn't exist ") % environment_id)
      elsif !environment.nil? && environment.organization != self.organization
        errors.add(:environment, _("name: %s doesn't exist ") % environment.name)
      end
    end

    def usage_count
      system_activation_keys.count
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
      added_pools = self.get_key_pools.map { |pool| pool["id"] }
      available_pools = all_pools - added_pools
      Pool.where(:cp_id => available_pools)
    end

    def products
      all_products = []

      cp_pools = self.get_key_pools
      if cp_pools
        pools = cp_pools.collect { |cp_pool| Pool.find_by(:cp_id => cp_pool['id']) }
        pools.each do |pool|
          all_products << pool.subscription.products
        end
      end
      all_products.flatten!
    end

    def available_content
      self.products.map(&:available_content).flatten.uniq { |product| product.content.id }
    end

    def valid_content_label?(content_label)
      self.available_content.map(&:content).any? { |content| content.label == content_label }
    end

    # sets up system when registering with this activation key - must be executed in a transaction
    def apply_to_system(system)
      if !max_content_hosts.nil? && !self.unlimited_content_hosts && usage_count >= max_content_hosts
        fail Errors::MaxContentHostsReachedException, _("Max Content Hosts (%{limit}) reached for activation key '%{name}'") % {:limit => max_content_hosts, :name => name}
      end
      system.environment_id = self.environment_id if self.environment_id
      system.content_view_id = self.content_view_id if self.content_view_id
      system.system_activation_keys.build(:activation_key => self)
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

    # subscribe to each product according the entitlements remaining
    # TODO: break up method
    # rubocop:disable MethodLength
    def subscribe_system(system)
      already_subscribed = []
      begin
        # sanity check before we start subscribing
        self.pools.each do |pool|
          fail _("Pool %s has no product associated") % pool.cp_id unless pool.product_id
          fail _("Unable to determine quantity for pool %s") % pool.cp_id unless pool.quantity
        end

        allocate = system.sockets.to_i
        Rails.logger.debug "Number of sockets for registration: #{allocate}"
        fail _("Number of sockets must be higher than 0 for system %s") % system.name if allocate <= 0

        # we sort just to make the order deterministig.
        self.pools.group_by(&:product_id).sort_by(&:first).each do |product_id, pools|
          product = Product.find_by_cp_id(product_id, self.organization)
          consumption = calculate_consumption(product, pools, allocate)

          Rails.logger.debug "Autosubscribing pools: #{consumption.map { |pool, amount| "#{pool.cp_id} => #{amount}" }.join(", ")}"
          consumption.each do |pool, amount|
            Rails.logger.debug "Subscribing #{system.name} to product: #{product_id}, consuming pool #{pool.cp_id} of amount: #{amount}"
            if entitlements_array = system.subscribe(pool.cp_id, amount)
              # store for possible rollback
              entitlements_array.each do |ent|
                already_subscribed << ent['id']
              end
            end
          end
        end
      rescue => e
        Rails.logger.error "Autosubscription failed, rolling back: #{already_subscribed.inspect}"
        already_subscribed.each do |entitlement_id|
          begin
            Rails.logger.debug "Rolling back: #{entitlement_id}"
            system.unsubscribe(entitlement_id)
          rescue => re
            Rails.logger.fatal "Rollback failed, skipping: #{re.message}"
          end
        end
        raise e
      end
    end

    def copy(new_name)
      new_key = ActivationKey.new
      new_key.name = new_name
      new_key.attributes = self.attributes.slice("description", "environment_id", "organization_id", "content_view_id", "max_content_hosts", "unlimited_content_hosts")
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

    private

    def set_default_content_view
      if self.environment && self.content_view.nil?
        self.content_view = self.environment.try(:default_content_view)
      end
    end

    def self.humanize_class_name(_name = nil)
      _("Activation Keys")
    end
  end
end
