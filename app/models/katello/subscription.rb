module Katello
  class Subscription < Katello::Model
    include Glue::Candlepin::CandlepinObject
    include Glue::Candlepin::Subscription
    include Katello::Authorization::Subscription
    has_many :products, :through => :subscription_products, :class_name => "Katello::Product"
    has_many :subscription_products, :class_name => "Katello::SubscriptionProduct", :dependent => :destroy, :inverse_of => :subscription

    has_many :pools, :class_name => "Katello::Pool", :inverse_of => :subscription, :dependent => :destroy

    belongs_to :organization, :class_name => "Organization", :inverse_of => :subscriptions

    scope :in_organization, ->(org) { where(:organization => org) }

    def self.with_subscribable_content
      joins(:products).
        where("#{Katello::Product.table_name}.id" => Product.with_subscribable_content)
    end

    def self.using_virt_who
      joins(:pools).where("#{Katello::Pool.table_name}.virt_who" => true)
    end

    def redhat?
      self.products.any? { |product| product.redhat? }
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
