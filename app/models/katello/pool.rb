module Katello
  class Pool < Katello::Model
    include Katello::Authorization::Pool

    attr_accessor :quantity_attached

    belongs_to :subscription, :inverse_of => :pools, :class_name => "Katello::Subscription"

    has_many :activation_keys, :through => :pool_activation_keys, :class_name => "Katello::ActivationKey"
    has_many :pool_activation_keys, :class_name => "Katello::PoolActivationKey", :dependent => :destroy, :inverse_of => :pool

    scope :in_org, -> (org_id) { joins(:subscription).where("#{Katello::Subscription.table_name}.organization_id = ?", org_id) }

    self.include_root_in_json = false

    include Glue::Candlepin::Pool
    include Glue::Candlepin::CandlepinObject

    scoped_search :on => :cp_id, :complete_value => true, :rename => :id, :only_explicit => true
    scoped_search :on => :quantity, :complete_value => true
    scoped_search :on => :start_date, :complete_value => true, :rename => :starts
    scoped_search :on => :end_date, :complete_value => true, :rename => :expires
    scoped_search :on => :ram, :complete_value => true
    scoped_search :on => :multi_entitlement, :complete_value => true
    scoped_search :on => :consumed, :complete_value => true
    scoped_search :on => :account_number, :complete_value => true, :rename => :account
    scoped_search :on => :contract_number, :complete_value => true, :rename => :contract
    scoped_search :on => :name, :in => :subscription, :complete_value => true, :rename => :name
    scoped_search :on => :support_level, :in => :subscription, :complete_value => true
    scoped_search :on => :sockets, :in => :subscription, :complete_value => true
    scoped_search :on => :cores, :in => :subscription, :complete_value => true
    scoped_search :on => :product_id, :in => :subscription, :complete_value => true
    scoped_search :on => :stacking_id, :in => :subscription, :complete_value => true
    scoped_search :on => :instance_multiplier, :in => :subscription, :complete_value => true

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
