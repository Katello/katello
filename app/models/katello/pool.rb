module Katello
  class Pool < Katello::Model
    include Katello::Authorization::Pool
    belongs_to :subscription, :inverse_of => :pools, :class_name => "Katello::Subscription"

    has_many :activation_keys, :through => :pool_activation_keys, :class_name => "Katello::ActivationKey"
    has_many :pool_activation_keys, :class_name => "Katello::PoolActivationKey", :dependent => :destroy, :inverse_of => :pool

    self.include_root_in_json = false

    include Glue::Candlepin::Pool
    include Glue::Candlepin::CandlepinObject

    scoped_search :on => :cp_id, :complete_value => true, :rename => :id
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

    # ActivationKey includes the Pool's json in its own'
    def as_json(*_args)
      self.remote_data.merge(:cp_id => self.cp_id)
    end

    def self.active(subscriptions)
      subscriptions.select { |s| s.active }
    end

    def self.expiring_soon(subscriptions)
      subscriptions.select { |s| (s.end_date.to_date - Date.today) <= DAYS_EXPIRING_SOON }
    end

    def self.recently_expired(subscriptions)
      today_date = Date.today

      subscriptions.select do |s|
        end_date = s.end_date.to_date
        today_date >= end_date && today_date - end_date <= DAYS_RECENTLY_EXPIRED
      end
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

    private

    def default_sort
      Pool.joins(:subscription).order("subscription.name")
    end
  end
end
