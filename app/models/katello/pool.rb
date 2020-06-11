module Katello
  class Pool < Katello::Model
    include Katello::Authorization::Pool
    belongs_to :subscription, :inverse_of => :pools, :class_name => "Katello::Subscription"

    has_many :pool_products, :class_name => "Katello::PoolProduct", :dependent => :destroy, :inverse_of => :pool
    has_many :products, :through => :pool_products, :class_name => "Katello::Product"

    has_many :pool_activation_keys, :class_name => "Katello::PoolActivationKey", :dependent => :destroy, :inverse_of => :pool
    has_many :activation_keys, :through => :pool_activation_keys, :class_name => "Katello::ActivationKey"

    has_many :subscription_facet_pools, :class_name => "Katello::SubscriptionFacetPool", :dependent => :delete_all
    has_many :subscription_facets, :through => :subscription_facet_pools

    belongs_to :organization, :class_name => 'Organization', :inverse_of => :pools
    belongs_to :hypervisor, :class_name => 'Host::Managed', :inverse_of => :hypervisor_pools

    scope :in_organization, ->(org_id) { where(:organization_id => org_id) }
    scope :for_activation_key, ->(ak) { joins(:activation_keys).where("#{Katello::ActivationKey.table_name}.id" => ak.id) }
    scope :expiring_in_days, ->(days) do
      return self if days.blank?
      where(["end_date < ?", days.to_i.days.from_now.end_of_day])
    end
    scope :upstream, -> { where.not(upstream_pool_id: nil) }

    include Glue::Candlepin::Pool
    include Glue::Candlepin::CandlepinObject

    scoped_search :on => :cp_id, :complete_value => true, :rename => :id, :only_explicit => true
    scoped_search :on => :upstream_pool_id, :complete_value => true, :only_explicit => true
    scoped_search :on => :quantity, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :start_date, :complete_value => true, :rename => :starts, :only_explicit => true
    scoped_search :on => :end_date, :complete_value => true, :rename => :expires, :only_explicit => true
    scoped_search :on => :ram, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :multi_entitlement, :complete_value => true
    scoped_search :on => :consumed, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :account_number, :complete_value => true, :rename => :account, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :contract_number, :complete_value => true, :rename => :contract, :validator => ScopedSearch::Validators::INTEGER
    scoped_search :on => :virt_who, :complete_value => true, :only_explicit => true
    scoped_search :on => :name, :relation => :subscription, :complete_value => true, :rename => :name
    scoped_search :on => :support_level, :relation => :subscription, :complete_value => true
    scoped_search :on => :sockets, :relation => :subscription, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :cores, :relation => :subscription, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :cp_id, :relation => :subscription, :complete_value => true, :only_explicit => true, :rename => :product_id

    scoped_search :on => :stacking_id, :complete_value => true, :only_explicit => true
    scoped_search :on => :instance_multiplier, :relation => :subscription, :complete_value => true, :validator => ScopedSearch::Validators::INTEGER, :only_explicit => true
    scoped_search :on => :pool_type, :complete_value => true, :rename => :type

    validates_lengths_from_database

    DAYS_RECENTLY_EXPIRED = 30

    def active?
      active
    end

    # used for notification bell
    def expiring_soon?
      days_until_expiration >= 0 &&
        days_until_expiration <= Setting[:expire_soon_days].to_i
    end

    # used for entitlements report template
    def days_until_expiration
      (end_date.to_date - Date.today).to_i
    end

    def recently_expired?
      Date.today >= end_date.to_date && (Date.today - end_date.to_date) <= DAYS_RECENTLY_EXPIRED
    end

    def quantity_available
      return -1 if self.quantity == -1
      return 0 unless self.quantity && self.consumed
      self.quantity - self.consumed
    end

    def type
      self.pool_type
    end

    def upstream?
      upstream_pool_id.present?
    end

    def import_audit_record(old_host_ids, new_host_ids = subscription_facets.pluck(:host_id))
      return if old_host_ids.empty? && new_host_ids.empty?
      pool_id = self.id
      Audited::Audit.new(
        :auditable_id => pool_id,
        :auditable_type => 'Katello::Pool',
        :action => 'update',
        :auditable_name => self.name,
        :audited_changes => {'host_ids' => [old_host_ids, new_host_ids]}
      ).save!
    end

    # Note - Audit hook added to find records based on column except associations to display audit information
    def self.audit_hook_to_find_records(keyname, change, _audit)
      if keyname =~ /_ids$/
        case keyname
        when 'host_ids'
          ::Host.where(:id => change)&.index_by(&:id)
        end
      end
    end

    private

    def default_sort
      Pool.joins(:subscription).order("subscription.name")
    end

    class Jail < ::Safemode::Jail
      allow :id, :name, :available, :quantity, :product_id, :contract_number, :type, :account_number, :start_date, :end_date, :organization, :consumed, :days_until_expiration
    end
  end
end

class ActiveRecord::AssociationRelation::Jail < Safemode::Jail
  allow :sort_by
end
