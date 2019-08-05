module Katello
  class Subscription < Katello::Model
    include Glue::Candlepin::CandlepinObject
    include Glue::Candlepin::Subscription
    include Katello::Authorization::Subscription

    has_many :pools, :class_name => "Katello::Pool", :inverse_of => :subscription, :dependent => :destroy

    belongs_to :organization, :class_name => "Organization", :inverse_of => :subscriptions

    scope :in_organization, ->(org) { where(:organization => org) }

    def self.subscribable
      product_ids = Product.subscribable.pluck(:id) + [nil]
      joins(:pools).joins("LEFT OUTER JOIN #{Katello::PoolProduct.table_name} pool_prod ON #{Pool.table_name}.id = pool_prod.pool_id")
        .where("pool_prod.product_id" => product_ids)
        .group("#{self.table_name}.id")
    end

    delegate :user_ids, :to => :organization

    def self.using_virt_who
      joins(:pools).where("#{Katello::Pool.table_name}.virt_who" => true)
    end

    def redhat?
      # for custom subscriptions, there is no separate marketing and engineering product
      #   so query our Products table and check there
      product = Katello::Product.where(:cp_id => self.cp_id, :organization => self.organization).first
      product.nil? || product.redhat?
    end

    def active?
      pools.any?(&:active?)
    end

    def expiring_soon?
      pools.any?(&:expiring_soon?)
    end

    def recently_expired?
      pools.any?(&:recently_expired?)
    end

    def multi_entitlement?
      pools.where("#{Katello::Pool.table_name}.multi_entitlement" => true).any?
    end

    def virt_who_pools
      pools.where("#{Katello::Pool.table_name}.virt_who" => true)
    end

    def virt_who?
      virt_who_pools.any?
    end

    def self.humanize_class_name(_name = nil)
      _("Subscription")
    end
  end
end
