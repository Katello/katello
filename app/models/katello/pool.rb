module Katello
  class Pool < Katello::Model
    include Katello::Authorization::Pool

    belongs_to :subscription, :inverse_of => :pools, :class_name => "Katello::Subscription"

    has_many :activation_keys, :through => :pool_activation_keys, :class_name => "Katello::ActivationKey"
    has_many :pool_activation_keys, :class_name => "Katello::PoolActivationKey", :dependent => :destroy, :inverse_of => :pool

    scope :in_organization, ->(org_id) { joins(:subscription).where("#{Katello::Subscription.table_name}.organization_id = ?", org_id) }
    scope :for_activation_key, ->(ak) { joins(:activation_keys).where("#{Katello::ActivationKey.table_name}.id" => ak.id) }

    self.include_root_in_json = false

    include Glue::Candlepin::Pool
    include Glue::Candlepin::CandlepinObject

    scoped_search :on => :cp_id, :complete_value => true, :rename => :id, :only_explicit => true
    scoped_search :on => :quantity, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :start_date, :complete_value => true, :rename => :starts
    scoped_search :on => :end_date, :complete_value => true, :rename => :expires
    scoped_search :on => :ram, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :multi_entitlement, :complete_value => true
    scoped_search :on => :consumed, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :account_number, :complete_value => true, :rename => :account, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :contract_number, :complete_value => true, :rename => :contract, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :virt_who, :complete_value => true, :only_explicit => true
    scoped_search :on => :name, :relation => :subscription, :complete_value => true, :rename => :name
    scoped_search :on => :support_level, :relation => :subscription, :complete_value => true
    scoped_search :on => :sockets, :relation => :subscription, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :cores, :relation => :subscription, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :product_id, :relation => :subscription, :complete_value => true
    scoped_search :on => :stacking_id, :relation => :subscription, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :instance_multiplier, :relation => :subscription, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER

    validates_lengths_from_database

    DAYS_EXPIRING_SOON = 120
    DAYS_RECENTLY_EXPIRED = 30

    def active?
      active
    end

    def expiring_soon?
      (end_date.to_date - Date.today) <= DAYS_EXPIRING_SOON
    end

    def recently_expired?
      Date.today >= end_date.to_date && (Date.today - end_date.to_date) <= DAYS_RECENTLY_EXPIRED
    end

    def quantity_available
      return 0 unless self.quantity && self.consumed
      self.quantity - self.consumed
    end

    def type
      self.pool_type
    end

    def products
      self.subscription.products if self.subscription
    end

    def host
      Katello::Host::SubscriptionFacet.find_by_uuid(host_id).try(:host) if host_id
    end

    private

    def default_sort
      Pool.joins(:subscription).order("subscription.name")
    end
  end
end
